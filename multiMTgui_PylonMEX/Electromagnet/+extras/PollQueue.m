classdef PollQueue < extras.Queue
    
    properties(SetAccess=protected)
        Data;
    end
    
    events
        NewData
    end
    
    methods(Access=protected)
        function internalSend(this,D)
            this.Data = cat(1,this.Data,{D});
            
            notify(this,'NewData');
        end
    end
    
    methods
        function this = PollQueue()
            this.Data = {};
        end

        function L = Length(this)
            L = numel(this.Data);
        end
        
        function Clear(this)
            this.Data = cell(0,1);
        end
        
        function D = popFront(this)
            if isempty(this.Data)
                D = {};
                return
            end
            
            D = this.Data{end};
            this.Data{end}=[];
        end
        
        function D = popBack(this)
            if isempty(this.Data)
                D = {};
                return
            end
            
            D = this.Data{1};
            this.Data{1}=[];
        end
        
        function Data = popAll(this)
            if isempty(this.Data)
                Data = {};
                return;
            end
            Data = this.Data;
            this.Data = {};
        end
        
        
    end
end