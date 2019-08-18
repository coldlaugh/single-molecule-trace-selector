%% 
% 
%  THIS IS A CLASSIFICATION LAYER WITH WEIGHTED CLASSES
%  PARAMETERS:
%  simrepsClassificationLayer(name, weight = [1;1])
%  name: the layer's name
%  weight: a vector representing the weights for each class.





classdef weightedClassificationLayer < nnet.layer.ClassificationLayer
        
    properties
        % (Optional) Layer properties
        Weight = [1;1];
    end

 
    methods
        
        %% Layer Constructor
        function layer = weightedClassificationLayer(varargin)           
            % (Optional) Create a myClassificationLayer

            % Layer constructor function goes here
            
            if nargin == 1
                layer.Name = varargin{1};
                layer.Weight = [1;1];
            elseif nargin == 2
                layer.Name = varargin{1};
                layer.Weight = varargin{2};
            end
            
            layer.Description = sprintf("Loss Function with Weight %s",num2str(layer.Weight));
            
        end
        %% Forward loss function
        function loss = forwardLoss(layer, Y, T)
            % Return the loss between the predictions Y and the 
            % training targets T
            %
            % Inputs:
            %         layer - Output layer
            %         Y     ? Predictions made by network
            %         T     ? Training targets
            %         omega     ? weight
            %
            % Output:
            %         loss  - Loss between Y and T
            
            %% Definition of the Weighted Loss function
            % $$E = -\frac{1}{N}\sum_i\sum_j \omega_j T_{ij}\log Y_{ij}$
            
            %% 
            N = max(size(T,4),1);
            if isa(Y,'gpuArray')
                omega = zeros(size(Y),'gpuArray');
            else
                omega = zeros(size(Y));
            end
            omega(1,1,:,:) = repmat([layer.Weight(1);layer.Weight(2)],[1,N]);
            e = T .* log(Y + 1e-8) .* omega;
            loss = - sum(e(:)) / N;
        end
        %% Backward Loss function
        function dLdY = backwardLoss(layer, Y, T)
            % Backward propagate the derivative of the loss function
            %
            % Inputs:
            %         layer - Output layer
            %         Y     ? Predictions made by network
            %         T     ? Training targets
            %
            % Output:
            %         dLdY  - Derivative of the loss with respect to the predictions Y
            
            %% Derivative of Loss Function
            % 
            % $$\frac{\partial E}{\partial Y_{ij}} = - \frac{1}{N}\omega_{j} \frac{T_{ij}}{Y_{ij}}$$
            % 
            
            
            N = max(size(T,4),1);
            if isa(Y,'gpuArray')
                omega = zeros(size(Y),'gpuArray');
            else
                omega = zeros(size(Y));
            end
            
            omega(1,1,:,:) = repmat([layer.Weight(1);layer.Weight(2)],[1,N]);
%             dLdY = - T .* omega ./Y / N;
            dLdY = - T .* omega ./(Y + 1e-8) / N;
            
        end
    end
end