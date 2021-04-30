classdef (ConstructOnLoad) serialevent < event.EventData
    properties
        SerialObject
        SerialEvent
    end
    
    methods
        function this = serialevent(SerialObject,SerialEvent)
            this.SerialObject = SerialObject;
            this.SerialEvent = SerialEvent;
        end
    end
end