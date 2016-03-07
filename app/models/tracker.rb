class Tracker
  include Mongoid::Document
  field :job_id
  field :job_class, type: String
  field :status, type: Symbol
  field :log_message, type: Array, default: []
  field :options, type: Hash, default: {}

  scope :working, -> { where('status' => :working) }
  scope :failed, -> { where('status' => :failed) }
  scope :queued, -> { where('status' => :queued) }

  def log(data)
    log_message.push(data)
    save
  end

  def failed(_error)
    self.status = :failed
    log(e.message)
  end

  def queued
    self.status = :queued
    log('queued')
  end

  def working
    self.status = :working
    log('working')
  end

  def finished
    self.status = :completed
    log('completed')
  end

  def set_options(opts)
    self.options = opts
    save
  end
end
