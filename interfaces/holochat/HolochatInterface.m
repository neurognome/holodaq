classdef HolochatInterface < Interface
    properties
        id
    end

    methods
        function obj = HolochatInterface(id, server, reset)
            if nargin < 2 || isempty(server)
                server = 'http://136.152.58.120:8000';
            end

            if nargin < 3 || isempty(reset)
                reset = true;
            end
            obj.id = id;
            obj.io = RESTio(server);
            if reset
                obj.io.reset(obj.id);
            end
        end
        
        function initialize(obj)
        end

        function send(obj, data, target)
            obj.io.post(data, target, obj.id, 'msg');
            pause(0.1);
        end

        function set_config(obj, data, target)
            obj.io.post(data, target, obj.id, 'config');
        end

        function out = get_config(obj)
            out = obj.io.read(obj.id, 30, 'config');
        end

        function out = read(obj, timeout)
            if nargin < 2 || isempty(timeout)
                timeout = 10;
            end
            out = obj.io.read(obj.id, timeout, 'msg');
        end

        function flush(obj)
            obj.io.flush(obj.id);
        end
        

    end
end