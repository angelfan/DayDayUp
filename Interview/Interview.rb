require File.dirname(__FILE__) + '/callbacks'
require File.dirname(__FILE__) + '/notification'

class Person
  attr_reader :name, :duty

  def initialize(name, duty)
    @name = name
    @duty = duty
  end
end

class Receptionist < Person
  def doorbell_sound(payload)
    puts "#{name}: #{payload[:message]} coming, I will open the door"
  end

  def ruby_engineer_station(payload)
    puts "#{name}: Give #{payload[:applicants]} a cup of water"
    puts "#{name}: #{payload[:applicants]} gei me a message" if payload[:message]
    RubyEngineer.questions
    Notifications.publish('ruby_interview', payload.merge(wait: 20))
  end
end

class Interviewer < Person
  include Callbacks
  define_callbacks :interview
  set_callback :interview, :before, :ready_for_interview

  def interview
    run_callbacks :interview do
      # sleep 20
      ask_questions
    end
  end

  def ask_questions
    puts "#{name}: ask questions ba la ba la"
  end

  def interview_reading
    puts "#{name}: reading for interview"
  end

  def doorbell_sound(_payload)
    puts "#{name}: I am fixing the bug, I won't open the door"
  end
end

class Interviewers
  include Callbacks
  define_callbacks :interview
  set_callback :interview, :before, :interview_reading
  set_callback :interview, :after, :notice_karen

  def initialize
    @interviewers = []
  end

  def interview
    run_callbacks :interview do
      # sleep 20
      ask_questions
    end
  end

  def ruby_interview(_payload)
    interview
  end

  def ask_questions
    @interviewers.each(&:ask_questions)
  end

  def interview_reading
    @interviewers.each(&:interview_reading)
  end

  def add_interviewer(interviewer)
    @interviewers << interviewer
  end

  def notice_karen
    puts '------third start-------'
    Notifications.publish('manager_interview')
  end
end

class Manager < Person
  def ask_question_in_english
    puts "#{name}: ba la ba la"
  end

  def manager_interview(_payload)
    ask_question_in_english
  end
end

class Applicants < Person
  include Callbacks
  define_callbacks :knock
  define_callbacks :answer
  set_callback :knock, :before, :deep_breath
  set_callback :answer, :after, :take_a_rest

  def initialize(name, duty = nil)
    super(name, duty)
  end

  def knock(object)
    run_callbacks :knock do
      puts "#{name}: I will press the doorbell"
      object.sound
    end
  end

  def say
    Notifications.publish('ruby_engineer_station', applicants: name)
  end

  private

  def answer(english = false)
    run_callbacks :answer do
      return puts 'I will unhappy' if english
      puts 'happy!!!'
    end
  end

  def deep_breath
    puts "#{name}: take a deep breath first"
  end

  def take_a_rest
    puts "#{name}: take a reset after interview"
  end
end

class RubyEngineer
  def self.questions
    puts 'give a questionnaire of ruby'
  end
end

class Company
  def initialize(name = nil)
    @name = name || 'Ekohe'
    @staffs = []
  end

  def add_staff(person)
    @staffs << person
  end

  def door
    @door ||= Door.new(Doorbell.new)
  end
end

class Door
  attr_reader :doorbell

  def initialize(doorbell)
    @doorbell = doorbell
  end

  def sound
    doorbell.sound
  end
end

class Doorbell
  def sound
    puts 'Doorbell: I am being ring'
    Notifications.publish('doorbell_sound', message: 'a stranger')
  end
end

class Story
  attr_reader :gavin, :company

  def initialize
    load_gavin
    load_company
  end

  def start
    puts '------first start--------'
    gavin.knock(company.door)

    puts '------second start-------'
    gavin.say
  end

  private

  def load_company
    @company = Company.new
    @company.add_staff(claire)
    @company.add_staff(vincent)
    @company.add_staff(julien)
    @company.add_staff(karen)
    [claire, vincent, julien].each do |staff|
      Notifications.subscribe('doorbell_sound', staff)
    end
    Notifications.subscribe('ruby_interview', interviewers)
    Notifications.subscribe('ruby_engineer_station', claire)
    Notifications.subscribe('manager_interview', karen)
  end

  def claire
    @claire ||= Receptionist.new('Claire Wang', 'I am a receptionist')
  end

  def interviewers
    @interviewers = Interviewers.new
    @interviewers.add_interviewer(vincent)
    @interviewers.add_interviewer(julien)
    @interviewers
  end

  def vincent
    @vincent ||= Interviewer.new('Vincent Zhang', 'ask more questions')
  end

  def julien
    @julien ||= Interviewer.new('Julien Lu', 'watching quietly')
  end

  def karen
    @karen ||= Manager.new('Karen Ning', 'non-technical questions')
  end

  def load_gavin
    @gavin ||= Applicants.new('gavin', 'applicants')
  end
end

Story.new.start
