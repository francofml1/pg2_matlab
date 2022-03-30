function [fitresult, gof] = createFit1(Fs, ber)
%CREATEFIT(FS,BER)
%  Create a fit.
%
%  Data for 'BER vs Fs' fit:
%      X Input : Fs
%      Y Output: ber
%      Weights : Fs
%  Output:
%      fitresult : a fit object representing the fit.
%      gof : structure with goodness-of fit info.
%
%  See also FIT, CFIT, SFIT.

%  Auto-generated by MATLAB on 23-Mar-2022 00:05:33


%% Fit: 'BER vs Fs'.
[xData, yData, weights] = prepareCurveData( Fs, ber, Fs );

% Set up fittype and options.
ft = fittype( 'exp2' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.StartPoint = [1.35983818518953 0.146202030709892 0 0.146202030709892];
opts.Weights = weights;

% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft, opts );

% Plot fit with data.
figure( 'Name', 'BER vs Fs' );
plot( fitresult, xData, yData );
% Label axes
xlabel( 'Fs', 'Interpreter', 'none' );
ylabel( 'ber', 'Interpreter', 'none' );
grid on

