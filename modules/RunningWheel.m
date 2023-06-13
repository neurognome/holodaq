classdef RunningWheel < Module
    properties
        reader
        saver
    end

    methods
        function obj = RunningWheel(dq, input_channel)
            io = DAQInput(dq, input_channel);
            obj.reader = Reader(io);
            obj.saver = Saver(obj.reader, 'running_wheel');
        end

        function save(obj)
            obj.saver.add_data(obj.reader.data);
        end
    end
end