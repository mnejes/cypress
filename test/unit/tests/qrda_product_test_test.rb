class QRDAProductTestTest  < ActiveSupport::TestCase

  setup do
    
    collection_fixtures('test_executions', '_id', "product_test_id")
    collection_fixtures('product_tests', '_id')
    collection_fixtures('bundles','_id')
    collection_fixtures('measures','_id','bundle')
  end


  test "should be able to retrieve eh measures for test creation" do 
    measures = QRDAProductTest.product_type_measures
    assert_equal Measure.top_level.count, measures.count, "Measure count incorrect"
    
  end

test "should be able to create and execute a test" do

  	measure_ids = ["8A4D92B2-3887-5DF3-0139-0D01C6626E46","8A4D92B2-3887-5DF3-0139-0D08A4BE7BE6"]
  	Delayed::Worker.delay_jobs = false
  	pt = QRDAProductTest.new(measure_ids: measure_ids, name:"In Test", effective_date: Cypress::MeasureEvaluator::STATIC_EFFECTIVE_DATE)
 
  	pt.save
  	pt.reload

  	assert_equal "ready", pt.state, "Test should be in a ready state"
  	assert_equal measure_ids, pt.measures.collect{|m| m.hqmf_id}, "Test should have the same measure_ids created with"


    

    assert_equal 1, pt.records.count , "Test should have created 1 record"
    qrda = Rack::Test::UploadedFile.new(File.join(Rails.root, 'test/fixtures/qrda/eh_test_results.xml'), "application/xml")
    
    execution = pt.execute({:results =>qrda})

    assert_equal 0,  execution.execution_errors.by_validation_type(:result_validation).length 
    qrda = Rack::Test::UploadedFile.new(File.join(Rails.root, 'test/fixtures/qrda/eh_test_results_bad.xml'), "application/xml")
    
    execution = pt.execute({:results =>qrda})

    assert execution, "Should be able to create and execution"
		Delayed::Worker.delay_jobs = true
	
  end

end
