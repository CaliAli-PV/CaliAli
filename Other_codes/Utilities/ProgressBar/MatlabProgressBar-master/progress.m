classdef progress < handle
    properties (Access = private)
        IterationList;
        ProgressBar;
    end

    methods (Access = public)
        % Class Constructor
        function obj = progress(in, varargin)
            if ~nargin
                return;
            end

            obj.IterationList = in;

            % Pass all varargins to ProgressBar() and create the progress bar.
            obj.ProgressBar = ProgressBar(length(in), varargin{:});
            
            % Force initialization of the ProgressBar.
            % This calls the public 'setup' method inherited from matlab.System,
            % which in turn calls setupImpl, setting TicObject and printing the bar.
            setup(obj.ProgressBar);
            
            % (No need to call printProgressBar() here because setupImpl already did)
        end

        % Class Destructor
        function delete(obj)
            obj.ProgressBar.step([], [], []);
            if ~isempty(obj.ProgressBar)
                obj.ProgressBar.release();
            end
        end

        function [varargout] = subsref(obj, S)
            % Check if this is a parenthesis indexing call.
            if strcmp(S(1).type, '()') && ~isempty(S(1).subs)
                % For example, if you index as k = progress(1:100),
                % MATLAB passes S(1).subs = {1:100}. (If you index like A(3), S{1}.subs{1} is used.)
                %
                % Here we assume that the second element of S(1).subs gives the current iteration index.
                % (Adjust the index extraction if your indexing is different.)
                idx = S(1).subs{2};
                if isnumeric(idx) && (idx > 1)
                    % For iteration indices greater than 1, update the bar.
                    obj.ProgressBar.step([], [], []);
                end
            end
            % Return the requested element from the wrapped iteration list.
            varargout = {subsref(obj.IterationList, S)};
        end

        function [m, n] = size(obj)
            [m, n] = size(obj.IterationList);
        end
    end
end