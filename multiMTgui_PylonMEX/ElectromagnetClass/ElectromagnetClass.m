classdef (Sealed) ElectromagnetClass < handle
    properties
        Axis = []
    end
    methods (Access = public)
        function this=ElectromagnetClass()
            this.Axis = [ElectromagnetAxis(1), ElectromagnetAxis(2)];
        end
        
    end
    
end

        
        