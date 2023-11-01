classdef FiberPowerControl < Module
    properties
        shutter
        hwp

        pwr_fun
        pwr

        shutter_params
        min_deg
        max_deg
        min_pwr
        max_pwr
    end

    methods
        function obj = FiberPowerControl(shutter, hwp, path_to_lut)
            if nargin < 3 || isempty(path_to_lut)
                calib = [];
            else
                calib = importdata(path_to_lut);
            end

            obj.get_pwr_fun(calib);
            obj.shutter = shutter;
            obj.hwp = hwp;
            obj.pwr = obj.min_pwr;
            obj.zero();
        end
        
        function get_pwr_fun(obj, calib)
            obj.pwr_fun = @(x) interp1(calib.powers, calib.degrees, x);
            obj.max_deg = calib.max_deg;
            obj.min_deg = calib.min_deg;
            obj.max_pwr = calib.max_power;
            obj.min_pwr = calib.min_power;
        end
        
        function deg = pwr2deg(obj, pwr)
            deg = obj.pwr_fun(pwr);
            if isnan(deg)
                error('Outside of range, cannot use this power');
            end
        end

        function open(obj)
            sweep = zeros(1, obj.shutter.io.n_outputs);
            sweep(obj.shutter.io.channel_idx) = 1;
            obj.shutter.io.interface.write(sweep);
        end 

        function close_all(obj)
            % this is kinda meh rn, because it closes everything, but
            % that's fine
            sweep = zeros(1, obj.shutter.io.n_outputs);
            sweep(obj.shutter.io.channel_idx) = 0;
            obj.shutter.io.interface.write(sweep);
        end

        function zero(obj)
            obj.hwp.moveto(obj.min_deg)
            obj.close_all()
        end
        
        function set_power(obj, pwr)
            obj.pwr = pwr;
            obj.pwr2deg(pwr); % run checks
        end

        function set_shutter(obj, duration, on_time, frequency, delay)
            if nargin < 5 || isempty(delay)
                delay = 0;
            end
            obj.shutter_params.duration = duration;
            obj.shutter_params.on_time = on_time;
            obj.shutter_params.frequency = frequency;
            obj.shutter_params.delay = delay;
        end

        function power(obj, pwr)
            obj.hwp.moveto(obj.pwr2deg(pwr));
        end

        function prepare(obj)
            % prepare hwp if power set
            if ~isempty(obj.pwr_fun)
                obj.hwp.moveto(obj.pwr2deg(obj.pwr));
            end

            % prepare shutter if shutter set
            duration = obj.shutter_params.duration;
            on_time = obj.shutter_params.on_time;
            frequency = obj.shutter_params.frequency;
            delay = obj.shutter_params.delay;
            n_pulses = max(1, obj.on_time/1000 * obj.frequency);
            if ~isempty(n_pulses)
                cycle = (1/frequency) * 1000;
                obj.shutter.set(cat(2, [delay+1:cycle:delay+on_time]', duration * ones(n_pulses, 1), ones(n_pulses, 1)));
                obj.shutter_params = [];
                obj.close_all();
            end
        end
    end
end