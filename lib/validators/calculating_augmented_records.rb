module Validators
  # This is a set of helper methods to assist in working with randomized
  # demographics on patients, so that population results for an augmented
  # record can be compared to the results of the original.
  class CalculatingAugmentedRecords < CalculatingSmokingGunValidator
    def initialize(measures, records, test_id = 'testaugmented', options = {})
      super
    end

    # Functions related to individual record calculation results
    def parse_and_save_record(record)
      record.extendedData['correlation_id'] = @test_id
      record.extendedData['medical_record_number'] = rand(1_000_000_000_000_000)
      record.save
      record
    rescue
      nil
    end

    # create a temporary saved record copy to do calculations on, then delete it
    def validate_calculated_results(rec, options)
      # mrn = rec.extendedData['medical_record_number']
      # return false unless mrn
      record = parse_and_save_record(rec.clone)
      product_test = ProductTest.find(record.extendedData['correlation_id'])
      @bundle = product_test.bundle
      return false unless record

      calc_job = Cypress::JsEcqmCalc.new('effective_date': Time.at(product_test.effective_date).in_time_zone.to_formatted_s(:number))
      results = calc_job.sync_job([record.id.to_s], product_test.measures.map { |mes| mes._id.to_s })
      calc_job.stop

      passed = compare_results(results, record, options)
      record.destroy
      passed
    end

    def compare_results(results, record, options)
      passed = true
      results_hash = results['Individual']
      @measures.each do |measure|
        # compare results to patient as it was initially calculated for product test (use original product patient id before cloning)
        orig_results = QDM::IndividualResult.where('patient_id': options[:orig_product_patient].id, 'measure_id': measure.id).first
        new_results = results_hash[measure.id.to_s][record.id.to_s]
        measure.population_ids.keys.each do |pop_id|
          if orig_results[pop_id] != new_results[pop_id]
            passed = false
            break
          end
        end
      end
      passed
    end
  end
end
