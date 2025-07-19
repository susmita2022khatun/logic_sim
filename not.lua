not_gate = class()

function not_gate:init(x_centroid , y_centroid , width)
    self.x_c = x_centroid
    self.y_c = y_centroid
    self.width = width
    self.pin_num = 1
    self.pin_i_av = true --for attachment purpose
    self.connected_to = "nill" --for attachment purpose

    self.pin_i_status = false
    self.deb_rad = self.width/20

    self.pin_x = self.x_c - self.width / 2
    self.pin_y = self.y_c
    self.pin_out_x = self.x_c + self.width / 2
    self.pin_out_y = self.y_c

    self.out_status = true
end

function not_gate:reset()
    self.pin_i_status = false
end

function not_gate:checkClick(x, y)
    print("Checking click at", x, y)

    local dx_u = x - self.pin_x
    local dy_u = y - self.pin_y
    if dx_u^2 + dy_u^2 <= self.deb_rad^2 then
        print("Upper pin clicked!")
        self.pin_i_status = not self.pin_i_status
    end


    self.out_status = not self.pin_i_status

end


function not_gate:color_update(status)
    if status then
        love.graphics.setColor(0 , 1, 0)  -- green
    else 
        love.graphics.setColor(1 , 0 , 0)  -- red
    end
end

function not_gate:render()

    local gate_width = self.width/4
    local gate_height = self.width/2
    local left = self.x_c - gate_width / 2
    local top = self.y_c - gate_height / 2

    
    love.graphics.setColor(1, 1, 1) -- white
    love.graphics.polygon("fill",left, top,left, top + gate_height,left + gate_width, self.y_c)

    self:color_update(self.pin_i_status)
    love.graphics.circle("fill", self.pin_x, self.pin_y, self.deb_rad)

    
    self.out_status = not self.pin_i_status
    self:color_update(self.out_status)
    love.graphics.circle("fill", self.pin_out_x, self.pin_out_y, self.deb_rad)

    
    love.graphics.setColor(1, 1, 1)
    love.graphics.line(self.pin_x + self.deb_rad, self.pin_y, left, self.pin_y)
    love.graphics.line(self.x_c + gate_width / 2, self.y_c, self.pin_out_x - self.deb_rad, self.y_c)
end

