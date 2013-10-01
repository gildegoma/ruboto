module Ruboto::Activity::Reload
  import org.ruboto.Log

  def onResume
    Log.d "Ruboto::Activity::Reload onResume"
    super

    @ruboto_activity_reload_receiver = ReloadReceiver.new(self)
    filter = android.content.IntentFilter.new(android.content.Intent::ACTION_VIEW)
    registerReceiver(@ruboto_activity_reload_receiver, filter)
    Log.d "Ruboto::Activity::Reload registered reload receiver"
  rescue Exception
    Log.e "Exception registering reload listener: #{$!.message}"
    Log.e $!.backtrace.join("\n")
  end

  def onPause
    super
    unregisterReceiver(@ruboto_activity_reload_receiver)
    @ruboto_activity_reload_receiver = nil
    Log.d "Ruboto::Activity::Reload unregistered reload receiver"
  rescue Exception
    Log.e "Exception unregistering reload listener: #{$!.message}"
    Log.e $!.backtrace.join("\n")
  end

  def ruboto_activity_reload(scripts)
    Log.d "Got reload intent: #{scripts}"
  end

  class ReloadReceiver < android.content.BroadcastReceiver
    def initialize(activity)
      super()
      @activity = activity
    end

    # FIXME(uwe):  I would like to receive a string array,
    #              but have not found a way to do that.
    def onReceive(context, reload_intent)
      Log.d "Got reload intent: #{reload_intent.inspect}"
      file = reload_intent.get_string_extra('file')
      if file
        Log.d "load file: #{file.inspect}"
        load file
      end
      if (reload_intent.get_string_extra('restart'))
        Log.d 'restart activity'
        if @activity.intent.action == android.content.Intent::ACTION_MAIN
           restart_intent = android.content.Intent.new(@activity.intent).setAction(android.content.Intent::ACTION_VIEW)
        else
           restart_intent = @activity.intent
        end
        @activity.startActivity(restart_intent)
        @activity.finish
        Log.d 'activity restarted'
      end
      Log.d 'reload complete.'
      true
    rescue Exception
      Log.e "Exception handling reload broadcast: #{$!.message}"
      Log.e $!.backtrace.join("\n")
    end
  end

end

