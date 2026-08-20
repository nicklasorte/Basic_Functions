function [FDR_dB,ED,VD,OTR,DeltaFreq,single_fdr_loss,trans_mask] = FDR_ModelII_app_vec(app,freq_sep,array_tx_rf,array_rx_if,array_tx_mask,array_rx_insert_loss,TXSlope,RXSlope,Delta_Freq_Step)
% FDR_ModelII_app_vec  Vectorized FDR per ITU-R SM.337-6, Annex 1, eq.2.
%   Loop-free drop-in equivalent of FDR_ModelII_app: identical signature and
%   outputs, but the per-separation loop is replaced by a single cross-
%   correlation. Matches the looped version to ~1e-6 dB (floating-point
%   round-off). See the VECTORIZATION NOTE near the computation.
%
%   [FDR_dB,ED,VD,OTR,DeltaFreq,single_fdr_loss,trans_mask] = ...
%       FDR_ModelII_app(app,freq_sep,array_tx_rf,array_rx_if, ...
%                       array_tx_mask,array_rx_insert_loss,TXSlope,RXSlope,Delta_Freq_Step)
%
%   INPUT CONVENTION (the four data arrays):
%     Each curve is a PAIR of equal-length, one-sided vectors that MUST end
%     at the on-tune point (offset 0, level 0):
%       array_tx_rf / array_rx_if           : positive frequency OFFSETS from
%           band center (MHz), listed largest -> 0 (i.e. descending to 0).
%       array_tx_mask / array_rx_insert_loss: POSITIVE attenuation / insertion
%           loss (dB) at the matching offset, also ending in 0. (Negated here.)
%     Element i of an offset vector pairs with element i of its level vector.
%     The smallest non-zero offset is treated as a half-bandwidth, so
%     TX_BW / RX_BW = 2 * (innermost offset).
%
%   TXSlope / RXSlope : roll-off beyond the last defined point.
%       []      -> extrapolate (log-linear) from the last two defined points.
%       numeric -> fixed slope in dB/decade (e.g. -60).
%
%   Delta_Freq_Step (optional) : frequency grid step in MHz. Default 1.
%       single_fdr_loss snaps to the nearest grid point, so use a finer step
%       if you need FDR at a non-integer separation.
%
%   OUTPUTS:
%     FDR_dB        : FDR (dB) over the DeltaFreq grid.
%     ED, VD        : assembled two-sided TX mask / RX selectivity, [offset, dB].
%     OTR           : on-tune rejection = min(FDR_dB). Nonzero when the TX
%                     emission is wider than the RX passband.
%     DeltaFreq     : frequency-separation axis (MHz).
%     single_fdr_loss : FDR at the grid point nearest freq_sep.
%     trans_mask    : [DeltaFreq', S_Tx'] -- the on-tune TX emission mask
%                     (dB-down) sampled over DeltaFreq.
%
%   STANDARDS NOTE:
%     FDR_dB is the discrete (uniform-grid Riemann-sum) form of SM.337-6
%     eq.(2):  FDR = 10*log10( SUM P(f) / SUM P(f)*H^2(f+df) ), with the TX
%     mask carried as power P(f)=10^(S_Tx/10) and the RX selectivity carried
%     in power-dB so that 10^(sumRx/10) is H^2(f+df). OTR=min(FDR_dB) is the
%     on-tune value, eq.(4). The on-tune clamp below (FDR=0 when RX_BW>=TX_BW)
%     follows the B_R>=B_T case of eq.(6) -- but note TX_BW/RX_BW here are
%     2*(innermost supplied offset), i.e. the supplied band edge, NOT the
%     3 dB bandwidth eq.(6) is defined on. The clamp affects only whether FDR
%     is forced to exactly 0 on-tune; it does not enter the integral.
%
%   NOTE: 'app' is a vestigial App-Designer handle, unused; kept for call
%   compatibility and threaded through to the local subfunctions.

LogLin = 1;

CF = 0;

% --- optional grid step ---------------------------------------------------
if nargin < 9 || isempty(Delta_Freq_Step)
    Delta_Freq_Step = 1;   % MHz
end

% --- input validation (fail loud on the silent-garbage cases) -------------
% Returns curves normalized to row vectors so either orientation is accepted.
[array_tx_rf, array_tx_mask] = ...
    localCheckCurve(array_tx_rf, array_tx_mask, 'TX', 'array_tx_rf', 'array_tx_mask');
[array_rx_if, array_rx_insert_loss] = ...
    localCheckCurve(array_rx_if, array_rx_insert_loss, 'RX', 'array_rx_if', 'array_rx_insert_loss');

if ~(isnumeric(freq_sep) && isscalar(freq_sep) && isfinite(freq_sep))
    error('FDR_ModelII_app:badFreqSep', ...
          'freq_sep must be a finite numeric scalar (MHz).');
end

localCheckSlope(TXSlope, 'TXSlope');
localCheckSlope(RXSlope, 'RXSlope');

if ~(isnumeric(Delta_Freq_Step) && isscalar(Delta_Freq_Step) && ...
        isfinite(Delta_Freq_Step) && Delta_Freq_Step > 0)
    error('FDR_ModelII_app:badStep', ...
          'Delta_Freq_Step must be a positive finite scalar (MHz).');
end

temp_freq_sep = max([max(array_rx_if)+1, max(array_tx_rf)+1, abs(freq_sep)]);
end_freq      = abs(temp_freq_sep);
start_freq    = -1*end_freq;

DeltaFreq = start_freq:Delta_Freq_Step:end_freq;

%BW_TX     =  [-array_tx_rf flip(array_tx_rf(1:(find(array_tx_rf==0,1)-1)))]';
%BW_RX     =  [-array_rx_if flip(array_rx_if(1:(find(array_rx_if==0,1)-1)))]';
%Mask_TX   =  [array_tx_mask flip(array_tx_mask(1:(find(array_tx_mask==0,1)-1)))]';
%Reject_RX = -[array_rx_insert_loss flip(array_rx_insert_loss(1:(find(array_rx_insert_loss==0,1)-1)))]';

BW_TX     =  [-array_tx_rf          flip(array_tx_rf(1:end-1))]';
BW_RX     =  [-array_rx_if          flip(array_rx_if(1:end-1))]';
Mask_TX   =  [ array_tx_mask        flip(array_tx_mask(1:end-1))]';
Reject_RX = -[ array_rx_insert_loss flip(array_rx_insert_loss(1:end-1))]';

ED = [BW_TX,   Mask_TX];
VD = [BW_RX, Reject_RX];

% Calculate Bandwidths (innermost offset -> half bandwidth)
idx1  = find(BW_RX == 0,1);
RXidx = idx1-1;
RX_BW = array_rx_if(RXidx)*2;
idx2  = find(BW_TX == 0,1);
TXidx = idx2-1;
TX_BW = array_tx_rf(TXidx)*2;

% Find Smallest Frequency Offset
Fmin = min(min(array_tx_rf(1:(TXidx))), min(array_rx_if(1:(RXidx))));

% Calculate Factor
dF = 10^(floor(log10(Fmin)))/10;
if dF > 1
    dF = 1;
end

% Pre-extrapolate the curves to 0 dB to deal with NaNs
[BRx,BwRx] = Extrap0dB(app, flip(-array_rx_insert_loss(1:RXidx)), flip(array_rx_if(1:RXidx)), RXSlope);
[BTx,BwTx] = Extrap0dB(app, flip(-array_tx_mask(1:TXidx)),        flip(array_tx_rf(1:TXidx)),  TXSlope);

% --- VECTORIZATION NOTE: FDR via cross-correlation (replaces the loop) ----
% On a padded grid at the internal integration step dF, the eq.(2) curve is
%   FDR(df) = 10*log10( sum(P) / (P correlate H2)(df) )
% with P  = TX power spectrum (centered at 0)  = 10^(S_tx/10)
%      H2 = RX power response (centered at 0)   = 10^(S_rx/10).
% The numerator is constant (total TX power); the denominator is the TX
% spectrum correlated against the RX response slid by df. This is the same
% sum the loop did point-by-point -- just evaluated for all df at once.
pad   = end_freq;                                  % pad so every lag has support
f_ext = (-(end_freq+pad)):dF:(end_freq+pad);
S_tx0 = makespectrumII(app,f_ext,CF,BTx,BwTx,TXSlope,LogLin);
S_rx0 = makespectrumII(app,f_ext,CF,BRx,BwRx,RXSlope,LogLin);
P  = 10.^(S_tx0/10);
H2 = 10.^(S_rx0/10);
Ne = numel(f_ext);
cc = conv(P, fliplr(H2));                          % full correlation, no loop
num = sum(P);
lags = round(DeltaFreq/dF);                        % DeltaFreq in dF samples
denom = cc(Ne + lags);                             % Ne = zero-lag index
FDR_dB = 10*log10(num ./ denom);
FDR_dB = FDR_dB(:);

% On-tune clamp (eq.6, B_R >= B_T case): FDR = 0 across the RX passband
if RX_BW >= TX_BW
    FDR_dB(abs(DeltaFreq) <= RX_BW/2) = 0;
end

OTR = min(FDR_dB);

% FDR at the grid point nearest the requested separation
[~,ind_fdr_loss] = min(abs(DeltaFreq-freq_sep));
single_fdr_loss  = FDR_dB(ind_fdr_loss);

% On-tune TX emission mask sampled over the DeltaFreq axis
S_Tx_ontune = makespectrumII(app,DeltaFreq,CF,BTx,BwTx,TXSlope,LogLin);
trans_mask  = horzcat(DeltaFreq', S_Tx_ontune');

end

% =========================================================================
function [b,bw] = Extrap0dB(app,b,bw,Slope)
[m,n] = size(b);

for i = 1:m
    nans = isnan(bw(i,2:n))|isnan(b(i,2:n));
    keep = logical([1 ~nans]);
    b(i,1:n)  = [b(i,keep)  nan(1,sum(nans))];
    bw(i,1:n) = [bw(i,keep) nan(1,sum(nans))];
end

for i = m:-1:1
    if isnan(bw(i,1))
        if isempty(Slope)
            if sum(~isnan(bw(i,2:n)))<2 % delete row if < 2 non-NaN
                bw = bw(1:i-1,:);
                b  = b(1:i-1,:);
            end
        else
            if sum(~isnan(bw(i,2:n)))<1 % delete row if < 1 non-NaN
                bw = bw(1:i-1,:);
                b  = b(1:i-1,:);
            end
        end
    else
        if isempty(Slope)
            if sum(~isnan(bw(i,2:n)))<1
                bw = bw(1:i-1,:);
                b  = b(1:i-1,:);
            end
        end
    end
end

[m,~] = size(b);

for i = 1:m
    if isnan(bw(i,1))
        if isnumeric(Slope) && ~isempty(Slope)
            b1  = b(i,1:find(isnan(b(i,2:end)), 1 ));
            bw1 = bw(i,1:find(isnan(bw(i,2:end)), 1 ));
            b1  = [b1 b1(end)+Slope]; %#ok
            bw1 = [bw1 10*bw1(end)];  %#ok
            if sum(~isnan(bw1(2:3)))==2
                b(i,1)  = 0;
                bw(i,1) = 10^interp1(b1(2:3),log10(bw1(2:3)),b(i,1),'linear','extrap');
            end
        else
            if sum(~isnan(bw(i,2:3)))==2
                b(i,1)  = 0;
                bw(i,1) = 10^interp1(b(i,2:3),log10(bw(i,2:3)),b(i,1),'linear','extrap');
            end
        end
    end
end
end

% =========================================================================
function S = makespectrumII(app,f,fc,b,bw,dB_dec,LogLin)
if b(1)~=0 % insert Zero if needed
    b  = [0 b];
    bw = [nan bw];
end

tmp = [0 isnan(b(2:end))|isnan(bw(2:end))]; %check for NaNs
if sum(tmp)
    b  = b(1:find(tmp==1, 1 )-1);
    bw = bw(1:find(tmp==1, 1 )-1);
end

if isnumeric(dB_dec) && ~isempty(dB_dec) %Add extrapolation point one decade out
    b  = [b b(end)+dB_dec];
    bw = [bw 10*bw(end)];
end

if isnan(bw(1)) % interpolate between points 2 and 3
    bw(1) = 10^interp1(b(2:3),log10(bw(2:3)),0,'linear','extrap');
elseif bw(1)==0 % make equal to the step size
    bw(1) = (f(2)-f(1));
end

if LogLin==1
    S = zeros(size(f));
    S(f~=fc) = interp1(log10(bw),b,log10(abs(f(f~=fc)-fc)),'linear','extrap');
else
    S = interp1((bw/2),b,(abs(f-fc)),'linear','extrap');
end

S(S>0) = 0;
end

% =========================================================================
function [off, lev] = localCheckCurve(off, lev, tag, offName, levName)
% Validate one (offset, level) curve pair and normalize to row vectors.
if ~(isnumeric(off) && isvector(off) && ~isempty(off))
    error('FDR_ModelII_app:badCurve', ...
          '%s curve: %s must be a non-empty numeric vector.', tag, offName);
end
if ~(isnumeric(lev) && isvector(lev) && ~isempty(lev))
    error('FDR_ModelII_app:badCurve', ...
          '%s curve: %s must be a non-empty numeric vector.', tag, levName);
end
off = off(:).';   % normalize to row
lev = lev(:).';

if numel(off) ~= numel(lev)
    error('FDR_ModelII_app:lengthMismatch', ...
          ['%s curve: %s and %s must be the same length ' ...
           '(offsets=%d, levels=%d).'], tag, offName, levName, numel(off), numel(lev));
end
if any(~isfinite(off)) || any(~isfinite(lev))
    error('FDR_ModelII_app:nonFinite', ...
          '%s curve: %s/%s contain NaN or Inf.', tag, offName, levName);
end
% Must end at the on-tune point (0,0).
if off(end) ~= 0 || lev(end) ~= 0
    error('FDR_ModelII_app:notEndingAtZero', ...
          ['%s curve: %s and %s must end at the on-tune point (0,0). ' ...
           'Got last entries offset=%g, level=%g.'], ...
          tag, offName, levName, off(end), lev(end));
end
% Offsets: one-sided, strictly descending to 0 (so the non-zero entries are
% positive, unique, and produce a monotonic axis when mirrored/flipped).
if any(off(1:end-1) <= 0)
    error('FDR_ModelII_app:nonPositiveOffset', ...
          ['%s curve: %s must be positive one-sided offsets ending at 0 ' ...
           '(no zero or negative values before the final 0).'], tag, offName);
end
if any(diff(off) >= 0)
    error('FDR_ModelII_app:offsetsNotDescending', ...
          ['%s curve: %s must be listed largest-to-smallest, ending at 0 ' ...
           '(strictly descending; duplicates break interpolation).'], tag, offName);
end
% Levels: POSITIVE attenuation/insertion loss in dB (negated internally).
% This is the big silent-garbage trap: negative dB zeroes the spectrum.
if any(lev < 0)
    error('FDR_ModelII_app:negativeLevel', ...
          ['%s curve: %s must be POSITIVE attenuation in dB ' ...
           '(it is negated internally). Negative values silently zero the ' ...
           'spectrum and produce a wrong-but-finite FDR.'], tag, levName);
end
% Levels should be non-increasing toward on-tune; warn (suspicious, not fatal).
if any(diff(lev) > 0)
    warning('FDR_ModelII_app:nonMonotonicLevel', ...
            ['%s curve: %s is not monotonically non-increasing toward 0. ' ...
             'Emission masks / selectivity are normally monotonic in |offset|; ' ...
             'proceeding, but check the ordering.'], tag, levName);
end
end

% =========================================================================
function localCheckSlope(s, name)
% Slope must be [] (auto-extrapolate) or a numeric scalar dB/decade.
if isempty(s)
    return
end
if ~(isnumeric(s) && isscalar(s) && isfinite(s))
    error('FDR_ModelII_app:badSlope', ...
          '%s must be [] or a finite numeric scalar (dB/decade).', name);
end
if s > 0
    warning('FDR_ModelII_app:positiveSlope', ...
            ['%s = %g dB/decade is positive; a roll-off slope is normally ' ...
             '<= 0 (attenuation increasing with offset). Proceeding as given.'], ...
            name, s);
end
end