; This is an example of IDL file with functions and procedures


;/ Brief description which ends at this dot. Details follow
;/ here.
;/ \brief Brief description should go here
;/ More complete description should go here
;/ @param parameter1 P1
;/ @param parameter1 P2
;/ @param option1    O1 (keyword)
;/ @return nada
PRO procedure_1, parameter1, parameter2, option1=option1
    ;! Description of line 1
    ;! Description of line 1
    ; line 3
END

pro procedure_2, parameter1, parameter2, option1=option1
    ; line 1
    ; line 2
    ; line 3
end


FUNCTION procedure_3, parameter1, parameter2, option1=option1
    ; line 1
    ; line 2
    ; line 3
    return 2.0 
END

function procedure_4, parameter1, parameter2
    ; line 1
    ; line 2
    ; line 3
    return 2.0 
END

