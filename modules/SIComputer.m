classdef SIComputer < Module
    properties
        trigger
        flip
        controller
    end
    
    methods
        function obj = SIComputer(trigger, flip, controller)
            if nargin < 3 
                controller = [];
            end
            obj.trigger = trigger;
            obj.flip = flip;    
            obj.controller = controller;
        end 

        function prepare(obj)
            obj.trigger.set([1, 25, 1]);
            obj.prepare@Module(); % how do we call superclass methods again?
        end
    end
end