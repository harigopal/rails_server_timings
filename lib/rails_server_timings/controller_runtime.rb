module RailsServerTimings
  module ControllerRuntime
    def process_action(*args)
      callback = lambda do |*_|
        event = ActiveSupport::Notifications::Event.new(*_)
        payload = event.payload
        timings = []

        payload.each do |key, value|
          if idx = key.to_s =~ /_runtime/
            timings << ("#{key[0, idx]}=%.1f" % value.to_f)
          end
        end

        timings << ("total=%.1f" % event.duration.to_f)

        response.headers['Server-Timing'] = timings.join(', ')
      end


      ActiveSupport::Notifications.subscribed(callback, 'process_action.action_controller') do
        super
      end
    end
  end
end