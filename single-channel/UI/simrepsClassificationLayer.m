classdef simrepsClassificationLayer < nnet.layer.ClassificationLayer
        
    properties
        % (Optional) Layer properties

        % Layer properties go here
        weight = [1,50];
        regulator = 0;
    end
 
    methods
        function layer = simrepsClassificationLayer(name, w)           
            % (Optional) Create a myClassificationLayer

            % Layer constructor function goes here
            
            if nargin == 1
                layer.Name = name;
            elseif nargin == 2
                layer.Name = name;
                layer.weight = w;
            end
            
            % Set layer description
            layer.Description = 'classification layer for simreps data';
            
        end

        function loss = forwardLoss(layer, Y, T)
            % Return the loss between the predictions Y and the 
            % training targets T
            %
            % Inputs:
            %         layer - Output layer
            %         Y     ? Predictions made by network
            %         T     ? Training targets
            %
            % Output:
            %         loss  - Loss between Y and T

            % Layer forward loss function goes here
            n = size(T,2);
            l = size(T,3);
            e = T.*log(Y).*repmat([layer.weight(1);layer.weight(2)],[1,n,l]);
            f = layer.regulator * repmat([1;0],[1,n,l]).*T.*(Y - 1).^2;
            loss = -sum(e(:)) / n / l - sum(f(:)) / n / l ;
        end
        
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

            % Layer backward loss function goes here
            
            n = size(T,2);
            l = size(T,3);
            dLdY = - T.*repmat([layer.weight(1);layer.weight(2)],[1,n,l])./Y/n/l - ...
                2*layer.regulator*repmat([1;0],[1,n,l]).*T.*(Y - 1) / n/l;
            
        end
    end
end