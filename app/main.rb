class Clicker
    attr_accessor :grid, :inputs, :state, :outputs

    def box
        #location: {
        #    0 => [1, 1],
        #}
        #visible: false
        #money_rate
        #time_rate
        #current_time
    end
    
    def tick
        defaults
        render
        calc
        process_inputs
    end

    def defaults
        state.main_size ||= 300
        state.constant_size ||= state.main_size
        state.money     ||= 0
        state.moneyPosX ||= 635
        state.rates     ||= [1, 0, 0, 0, 0, 0, 0, 0, 0, 0]
        state.visible   ||= [true, false, false, false, false, false, false, false, false, false]
        #state.visible   ||= [true, true, true, true, true, true, true, true, true, true] #for GUI
        state.boxesCord ||= [750, 600]
        state.rectSize  ||= [150, 50]
        state.distance  ||= [state.rectSize[0] + 25, state.rectSize[1] + 25]
    end

    def render
        outputs.sprites << [500 - (state.main_size / 2), 360 - (state.main_size / 2),
                            state.main_size, state.main_size, "sprites/circle-gray.png"]

        outputs.labels << [145, 680, "Money:"]
        outputs.labels << [163, state.moneyPosX, "$" + state.money.to_s]
        outputs.borders << [75, 600, 200, 50]

        deltaX = 0
        deltaY = 0
        state.visible.length.times do |n|
            if state.visible[n] == true
                outputs.borders << [state.boxesCord[0] + (state.distance[0] * deltaX),
                                    state.boxesCord[1] - (state.distance[1] * deltaY),
                                    state.rectSize[0], state.rectSize[1]]
            end
            deltaX += 1
            if deltaX % 3 == 0
                deltaX = 0
                deltaY += 1
            end
        end
    end

    def calc
        if state.money < 0
            puts("MISTAKE SOMEWHERE")
        end
        if state.main_size > state.constant_size
            state.main_size -= 1
        end
    end

    def process_inputs
        if inputs.keyboard.key_down.space && state.constant_size == state.main_size
            state.money += state.rates[0]
            state.main_size += 7
            inputs.keyboard.clear
        end
    end

end

$clicker = Clicker.new

def tick args
    $clicker.grid    = args.grid
    $clicker.inputs  = args.inputs
    $clicker.state   = args.state
    $clicker.outputs = args.outputs
    $clicker.tick
end

