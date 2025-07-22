or_gate = class()

function or_gate:init(x_centroid , y_centroid , pin_gap , width)
    self.x_c = x_centroid
    self.y_c = y_centroid
    self.pin_gap = pin_gap
    self.width = width
    self.pin_num = 2
    self.pin_u_av = true --for attachment purpose 
    self.pin_d_av = true --for attachment purpose
    self.connected_to = nil --for attachment purpose
    self.connected_from = nil

    self.pin_u_status = false
    self.pin_d_status = false
    self.deb_rad = self.width/20

    self.pin_x = self.x_c - self.width / 2
    self.pin_u_y = self.y_c - self.pin_gap / 2 +self.deb_rad
    self.pin_d_y = self.y_c + self.pin_gap / 2 -self.deb_rad
    self.pin_out_x = self.x_c + self.width / 2
    self.pin_out_y = self.y_c

    self.out_status = false
end

function or_gate:reset()
    self.pin_u_status = false
    self.pin_d_status = false
end

function or_gate:checkClick(x, y)
    print("Checking click at", x, y)

    local dx_u = x - self.pin_x
    local dy_u = y - self.pin_u_y
    if dx_u^2 + dy_u^2 <= self.deb_rad^2 then
        print("Upper pin clicked!")
        self.pin_u_status = not self.pin_u_status
    end

    local dx_d = x - self.pin_x
    local dy_d = y - self.pin_d_y
    if dx_d^2 + dy_d^2 <= self.deb_rad^2 then
        print("Lower pin clicked!")
        self.pin_d_status = not self.pin_d_status
    end

    self.out_status = self.pin_u_status or self.pin_d_status

end


function or_gate:color_update(status)
    if status then
        love.graphics.setColor(0 , 1, 0)  -- green
    else 
        love.graphics.setColor(1 , 0 , 0)  -- red
    end
end

function or_gate:render()

    local gate_width = self.width/4
    local gate_height = self.width/2
    local left = self.x_c - gate_width / 2
    local top = self.y_c - gate_height / 2

    
    love.graphics.setColor(1, 1, 1) -- white
    love.graphics.rectangle("fill", left, top, gate_width / 2, gate_height)

    love.graphics.arc("fill",  self.x_c, self.y_c, gate_height / 2, -math.pi/2, math.pi/2 , 50)

    love.graphics.setColor(0, 0, 0)
    love.graphics.arc("fill",  left, self.y_c, gate_height / 2, -math.pi/2, math.pi/2 , 50)


    self:color_update(self.pin_u_status)
    love.graphics.circle("fill", self.pin_x, self.pin_u_y, self.deb_rad)

    self:color_update(self.pin_d_status)
    love.graphics.circle("fill", self.pin_x, self.pin_d_y, self.deb_rad)


    self.out_status = self.pin_u_status or self.pin_d_status
    self:color_update(self.out_status)
    love.graphics.circle("fill", self.pin_out_x, self.pin_out_y, self.deb_rad)

    
    love.graphics.setColor(1, 1, 1)
    love.graphics.line(self.pin_x + self.deb_rad, self.pin_u_y, left, self.pin_u_y)
    love.graphics.line(self.pin_x + self.deb_rad, self.pin_d_y, left, self.pin_d_y)
    love.graphics.line(self.x_c + gate_width / 2, self.y_c, self.pin_out_x - self.deb_rad, self.y_c)
end

