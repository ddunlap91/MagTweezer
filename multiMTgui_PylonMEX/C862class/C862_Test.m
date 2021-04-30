%% C-862 Test Script

%Setup serial Communication
PORT = 'COM4'; %com port to talk to
BAUD = 9600;
c862_com = serial(PORT,'Baudrate',BAUD,'DataBits',8,'StopBits',1,'Parity','none');

%set terminator
set(c862_com,'terminator',{3,'CR'});


fopen(c862_com);

%Test the Connection
fprintf(c862_com,'TP');
t1=tic;
while c862_com.BytesAvailable<=0
    if toc(t1)>2
        disp('time out. did not get a response in < 2s');
        break;
    end
end
if c862_com.BytesAvailable>0
    resp = fgetl(c862_com);
    fprintf('Recieved: %s\n',resp);
    fprintf('Bytes Available: %d\n',c862_com.BytesAvailable);
end

%Find connected devices
for b=0:3
    str=[1,sprintf('%dxx',b)];
    fprintf(c862_com,str);
    fprintf(c862_com,'TB');
    while c862_com.BytesAvailable<=0
        if toc(t1)>2
            disp('time out. did not get a response in < 2s');
            break;
        end
    end
    if c862_com.BytesAvailable>0
        resp = fgetl(c862_com);
        fprintf('Recieved: %s\n',resp);
        fprintf('Bytes Available: %d\n',c862_com.BytesAvailable);
    else
        fprintf('did not find board: %d\n',b);
    end
end

%Disconnect
disp('closing com connection');
fclose(c862_com);
delete(c862_com);
clear c862_com;