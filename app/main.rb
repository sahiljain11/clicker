class Box
    attr_reader :id, :location, :threshold_val, :visible, :money_rate, :current_time, :current_level,
                :final_level, :price, :vis_threshold

    def initialize (id_num, x, y)
        @id            = id_num
        @location      = [x, y]
        @vis_threshold = 10**id_num
        @visible       = false
        @money_rate    = @id**5
        @current_time  = 0
        @current_level = 0
        @price         = 2 * 10**id_num
        @final_level   = 5
        @time_interval = 10
        puts("Testing?" + " " + vis_threshold.to_s)
    end

    def update (current_money)
        @current_time += 1 if current_level != 0
        update_visibility(current_money)
        return update_money(current_money)
    end

    def update_visibility (current_money)
        @visible = true if current_money >= @vis_threshold && @visible == false
    end

    def update_money (current_money)
        current_money += @money_rate if @current_time == @time_interval
        return current_money
    end

    def purchase (current_money)
        if @price < current_money && @current_level != @final_level
            current_money -= @price
            @price *= 1.25
            @current_level += 1
            @time_interval /= 2
            @money_rate *= 1.25
        end
        return current_money
    end
    
end

class Clicker
    attr_accessor :grid, :inputs, :state, :outputs

    def tick
        defaults
        render
        calc
        process_inputs
    end

    def defaults
        #instantiate all of the defaults
        state.main_size     ||= 300
        state.constant_size ||= state.main_size
        state.money         ||= 0
        state.boxes_cord    ||= [750, 600]
        state.rect_size     ||= [150, 50]
        state.distance      ||= [state.rect_size[0] + 25, state.rect_size[1] + 25]
        state.num_boxes     ||= 5
        state.boxes         ||= []

        
        #create all of the boxes and instantiate their attributes
        if state.boxes == []
            deltaX = 0
            deltaY = 0
            state.num_boxes.times do |count|
                state.boxes.push(Box.new(count + 1, state.boxes_cord[0] + (state.distance[0] * deltaX),
                                         state.boxes_cord[1] - (state.distance[1] * deltaY)))
                deltaX += 1
                if deltaX % 3 == 0
                    deltaX = 0
                    deltaY += 1
                end
            end
        end
    end

    def render
        #get the basic button in the middle (the clicker)
        outputs.sprites << [500 - (state.main_size / 2), 360 - (state.main_size / 2),
                            state.main_size, state.main_size, "sprites/circle-gray.png"]

        #get the current amount of money present
        outputs.labels << [145, 680, "Money:"]
        outputs.labels << [170, 635, "$" + state.money.to_s, 1, 1]
        outputs.borders << [75, 600, 200, 50]

        #render boxes if they're visible
        state.num_boxes.times do |n|
            if state.boxes[n].visible == true
                    outputs.borders << [state.boxes[n].location[0], state.boxes[n].location[1],
                                        state.rect_size[0], state.rect_size[1]]
            end
        end
    end

    def calc
        if state.money < 0
            puts("MISTAKE SOMEWHERE")
        end

        #update animation of clicking the button
        if state.main_size > state.constant_size
            state.main_size -= 1
        end

        #update the boxes based on time intervals and money
        state.num_boxes.times do |n|
            state.money = state.boxes[n].update(state.money)
        end
        
    end

    def process_inputs
        #update basic money increases from pressing space
        if inputs.keyboard.key_down.space && state.constant_size == state.main_size
            state.money += 1
            state.main_size += 7
            inputs.keyboard.clear
        end

        #add purchasing
        state.num_boxes.times do |n|
            if inputs.keyboard.key_down.((":" + n.to_s).to_e)
                state.money = state.boxes[n - 1].purchase(state.money)
            end
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

