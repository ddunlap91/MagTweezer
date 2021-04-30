classdef CallbackQueue < extras.Queue
    
    
    properties(Access=protected)
        Callbacks = {}
    end
    
    methods
        function afterEach(this,fcn)
            assert(isa(fcn,'function_handle'),'fcn must be a function handle');
            this.Callbacks = cat(1,this.Callbacks,{fcn});
            
        end
    end
    methods (Access=protected)
        function internalSend(this,D)

            for n=1:numel(this.Callbacks)
                this.Callbacks{n}(D);
            end

        end
    end
end