require_relative '../name_day_calendar'

describe NameDayCalendar do
  describe '.new' do
    it 'takes two arguments' do
      expect { NameDayCalendar.new }.to raise_exception ArgumentError
      expect { NameDayCalendar.new('march') }.to raise_exception ArgumentError
      expect { NameDayCalendar.new('march', 25) }.not_to raise_exception
      expect { NameDayCalendar.new('march', 25, '') }.to raise_exception ArgumentError
    end
  end

  let(:march_25_results) do
    {
      'Austria' => ['Verkündung des Herrn'],
      'Bulgaria' => ['Blaga', 'Blago', 'Blagovest'],
      'Croatia' => ['Irenej']
    }
  end

  describe '#get_name_days' do
    context 'validates arguments of .new' do
      it 'first argument should be a correct month name' do
        expect do
          NameDayCalendar.new(0, 1).get_name_days
          NameDayCalendar.new('mayy', 1).get_name_days
        end.to raise_exception(NameDayCalendar::InvalidMonth)
      end

      it 'second argument should be an integer' do
        expect do
          NameDayCalendar.new('may', '').get_name_days
        end.to raise_exception(TypeError)
      end

      it 'second argument should be a proper day of month' do
        expect do
          NameDayCalendar.new('may', 0).get_name_days
          NameDayCalendar.new('may', 32).get_name_days
        end.to raise_exception(NameDayCalendar::InvalidRange)
      end
    end

    context 'gets page' do
      before { OpenURI.should_receive(:open_uri).with(uri_ndc) }

      let(:ndc) { NameDayCalendar.new('march', 25) }
      let(:uri_ndc) { URI('http://www.namedaycalendar.com/march/25')}
      let(:march_25_fixtures) { Nokogiri::HTML(IO.read("spec/fixtures/march_25")) }

      it 'should connect to right site' do
        ndc.get_name_days
      end

      it 'should return hash' do
        ndc.get_name_days.should be_a Hash
      end

      it 'should return hash with countries and names' do
        Nokogiri.stub(HTML: march_25_fixtures)
        ndc.get_name_days.should == march_25_results
      end
    end
  end

  describe '#print_name_days' do
    it 'should print data in proper format' do
      ndc = NameDayCalendar.new('march', 25)
      ndc.stub(get_name_days: march_25_results)

      ndc.should_receive(:puts).with('MARCH/25')
      ndc.should_receive(:puts).with('-' * 20)
      ndc.should_receive(:puts).with('| Austria => Verkündung des Herrn')
      ndc.should_receive(:puts).with('| Bulgaria => Blaga, Blago, Blagovest')
      ndc.should_receive(:puts).with('| Croatia => Irenej')
      ndc.should_receive(:puts).with('-' * 20)

      ndc.print_name_days
    end
  end

  describe 'CLI' do
    context 'with no params' do
      it 'should print help message to enter month and day' do
        IO.popen('ruby name_day_calendar.rb', 'r') do |ruby_app|
          ruby_app.read.should == "usage: name_day_calendar.rb MONTH DAY\nplease enter correct month and day.\n"
        end
      end
    end

    context 'with params' do
      it "should print help message to enter month if it's not valid" do
        IO.popen('ruby name_day_calendar.rb mayy', 'r') do |ruby_app|
          ruby_app.read.should == "usage: name_day_calendar.rb MONTH DAY\nplease enter correct month.\n"
        end
      end

      it "should print help message to enter day if it's not valid" do
        IO.popen('ruby name_day_calendar.rb may x', 'r') do |ruby_app|
          ruby_app.read.should == "usage: name_day_calendar.rb MONTH DAY\nplease enter correct day of month.\n"
        end
      end
    end
  end
end
