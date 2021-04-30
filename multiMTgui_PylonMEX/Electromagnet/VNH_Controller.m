classdef VNH_Controller < extras.hardware.TargetValueDevice & extras.hardware.SerialDevice
    
    %% redefine TargetValue here because we want a custom set method
    properties (SetObservable=true) %allow setting Target to same Target, that way wr message gets sent again
        Target = NaN
    end
    properties (SetAccess=protected,SetObservable=true,AbortSet=true)
        Value = NaN
        
        Channels = 2;
    end

    %% Internal Use
    properties (Access=protected)
        DataListener
        ConnectListener
    end
    
    %% Overload connection validator
    methods (Access=protected)
        function validateConnection(this)
            %% Wait for startup sequence to be initiated
            disp('Waiting for current controller startup');
            disp(fscanf(this.scom));
        end
    end
    
    %% Create/Delete
    methods
        function this = VNH_Controller(Port)
            
            if ~exist('Port','var')
                Port = [];
            end
            
            %default serialdevice construction (do not connect yet)
            this@extras.hardware.SerialDevice();
            
            this.Port = Port;
            %% Device Info
            this.DeviceName = 'VNHx';
            this.Units = '';
            this.Limits = [-255,255];
            this.ValueSize = [this.Channels,1];
            
            %% Serial Com parameters
            this.BaudRate = 115200;
            this.DataBits = 8;
            this.StopBits = 1;
            this.Parity = 'none';
            this.Terminator = 'CR';
            
            %% Subscribe to ByteAvailable Notifications
            this.DataListener = addlistener(this,'DataRecieved',@(~,~) this.ParseMessage);
            
            %% Subscribe to Connection changes
            this.ConnectListener = addlistener(this,'connected','PostSet', @(~,~) this.ConnectChange());
            
            %% Connect if port specified
            if ~isempty(this.Port)
                this.ConnectCOM()
            end
            
            %% check connection
            this.ConnectChange();
        end
        
        function delete(this)
            
            delete(this.DataListener)
            delete(this.ConnectListener);
        end
    end
    
    %% Callbacks
    methods (Hidden)
        function ParseMessage(this)
            t = tic;
            vals = NaN(this.ValueSize);
            
            while this.BytesAvailable > 1
                if toc(t)>10
                    error('Timed out while processing Serial messages')
                end
                
                msg = fscanf(this.scom);
                
                
                [rx,ex]=regexp(msg,'Set\[\d\]=[-\d\.]+');
                
                for n=1:numel(rx)
                    v = sscanf(msg(rx(n):ex(n)),'Set[%d]=%d',2);
                    assert(numel(v)==2,'could not parse');
                    
                    vals(v(1)) = v(2);
                end
                
                
                [rx,ex]=regexp(msg,'Get\[\d\]=[-\d\.]+');
                for n=1:numel(rx)
                    v = sscanf(msg(rx(n):ex(n)),'Get[%d]=%d',2);
                    assert(numel(v)==2,'could not parse');
                    
                    vals(v(1)) = v(2);
                end 
           
            end
            this.Value(~isnan(vals)) = vals(~isnan(vals));
        end
        
        function ConnectChange(this)
            if ~this.connected %not connected
                this.Value = NaN;
                this.Target = NaN;
                
                try
                    stop(this.ValueTimer)
                catch
                end
            else
                this.Target = [0;0];
                
                for n=1:this.Channels
                    fprintf(this.scom,'get %d\n',n,'sync');
                end
            end
        end
        
    end
    
    %% Set Methods
    methods
        function set.Target(this,val)
            if ~this.connected
                this.Target = NaN;
                return;
            end
            
            assert(numel(val)==this.Channels, 'values must be 2x1');
            
            if any(isnan(val))
                warning('Target must be a number -255<=V<255');
                return;
            end
            
            val = round(max(-255,min(val,255)));
            
            str = 'setall ';
            for n=1:this.Channels
                str = [str,num2str(val(n)),' '];
            end

            this.fprintf(str);
            
            this.Target = val;
            
        end
    end
    
    
    
end