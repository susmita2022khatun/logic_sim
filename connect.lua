function connect_gate_load_to(prec_gate)
    local X, Y, S
    if prec_gate.pin_num == 2 then
        if prec_gate.pin_d_av then
            X = prec_gate.x_c - prec_gate.width
            Y = prec_gate.y_c + prec_gate.pin_gap / 2
            prec_gate.pin_d_av = false
            S = "d"
        elseif prec_gate.pin_u_av then
            X = prec_gate.x_c - prec_gate.width
            Y = prec_gate.y_c - prec_gate.pin_gap / 2
            prec_gate.pin_u_av = false
            S = "u"
        end
    else
        if prec_gate.pin_i_av then
            X = prec_gate.x_c - prec_gate.width
            Y = prec_gate.y_c
            prec_gate.pin_i_av = false
            S = "i"
        end
    end
    return X, Y, S
end

function connect_gate_update(prec_gate, suc_gate)
    if prec_gate.pin_num == 2 then
        if suc_gate.connected_to == "d" then
            prec_gate.pin_d_status = suc_gate.out_status
        elseif suc_gate.connected_to == "u" then
            prec_gate.pin_u_status = suc_gate.out_status
        end
    else
        prec_gate.pin_i_status = suc_gate.out_status
    end
end