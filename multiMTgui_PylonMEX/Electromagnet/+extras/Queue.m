classdef Queue <handle & matlab.mixin.Heterogeneous
% A simple que 
    methods (Static, Sealed, Access = protected)
       function default_object = getDefaultScalarElement
           default_object = extras.PollQueue;
       end
    end
    methods (Abstract, Access=protected)
      % Not implemented by Queue Class
      internalSend(obj,data)
    end
    
    methods (Sealed)
        function send(queueArray,data)
            for n=1:numel(queueArray)
                queueArray(n).internalSend(data);
            end
        end
    end
    
    methods (Sealed)
        function tf = eq(A,B)
            tf = eq@handle(A,B);
        end
        function tf = ne(A,B)
            tf = ne@handle(A,B);
        end
    end
    
end