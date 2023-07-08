
#==============================================================================#
#                         Better Fast-forward Mode                             #
#                                   v1.0                                       #
#                                                                              #
#                                 by Marin                                     #
#==============================================================================#
#                                   Usage                                      #
#                                                                              #
# SPEEDUP_STAGES are the speed stages the game will pick from. If you click F, #
# it'll choose the next number in that array. It goes back to the first number #
#                                 afterward.                                   #
#                                                                              #
#             $GameSpeed is the current index in the speed up array.           #
#   Should you want to change that manually, you can do, say, $GameSpeed = 0   #
#                                                                              #
# If you don't want the user to be able to speed up at certain points, you can #
#                use "pbDisallowSpeedup" and "pbAllowSpeedup".                 #
#==============================================================================#
#                    Please give credit when using this.                       #
#==============================================================================#

PluginManager.register({
                         :name => "Better Fast-forward Mode",
                         :version => "1.1",
                         :credits => "Marin",
                         :link => "https://reliccastle.com/resources/151/"
                       })

# When the user clicks F, it'll pick the next number in this array.
#KurayX
SPEEDUP_STAGES = [1,2,3,4,5]


def pbAllowSpeedup
  $CanToggle = true
end

def pbDisallowSpeedup
  $CanToggle = false
end

# Default game speed.
$GameSpeed = 0
System.set_window_title(System.game_title + " | Kuray's PIF Revamp v" + KURAYVERSION + " | Speed: x" + ($GameSpeed+1).to_s)
$frame = 0
$CanToggle = true

module Graphics
  class << Graphics
    alias fast_forward_update update
  end

  def self.update
    if $CanToggle && Input.trigger?(Input::AUX2)
      if File.exists?("TheDuoDesign.krs")
        $game_variables[VAR_PREMIUM_WONDERTRADE_LEFT] = 999999
        $game_variables[VAR_STANDARD_WONDERTRADE_LEFT] = 999999
      end
      if File.exists?("Kurayami.krs") || File.exists?("DebugAllow.krs")
        if $DEBUG
          $DEBUG = false
        else
          $DEBUG = true
        end
      else
        $GameSpeed = 0
        System.set_window_title(System.game_title + " | Kuray's PIF Revamp v" + KURAYVERSION + " | Speed: x" + ($GameSpeed+1).to_s)
      end
      # $GameSpeed = 4 if $GameSpeed < 0
      #KurayX
    end
    if $CanToggle && Input.trigger?(Input::AUX1)
      $GameSpeed += 1
      $GameSpeed = 0 if $GameSpeed >= SPEEDUP_STAGES.size
      #KurayX
      System.set_window_title(System.game_title + " | Kuray's PIF Revamp v" + KURAYVERSION + " | Speed: x" + ($GameSpeed+1).to_s)
    end
    $frame += 1
    return unless $frame % SPEEDUP_STAGES[$GameSpeed] == 0
    fast_forward_update
    $frame = 0
  end
end