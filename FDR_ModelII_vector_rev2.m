function [FDR_dB,ED,VD,OTR,DeltaFreq,single_fdr_loss,trans_mask] = FDR_ModelII_vector_rev2(app,freq_sep,array_tx_rf,array_rx_if,array_tx_mask,array_rx_insert_loss,TXSlope,RXSlope,Delta_Freq_Step)
%   Vectorized FDR per ITU-R SM.337-6, Annex 1, eq.2.
%
%   [FDR_dB,ED,VD,OTR,DeltaFreq,single_fdr_loss,trans_mask] = ...
%       FDR_ModelII_vector_rev2(app,freq_sep,array_tx_rf,array_rx_if, ...
%       array_tx_mask,array_rx_insert_loss,TXSlope,RXSlope,Delta_Freq_Step)
%
%   INPUT CONVENTION (the four data arrays):
%     Each curve is a PAIR of equal-length, one-sided vectors that MUST end
%     at the on-tune point (offset 0, level 0):
%       array_tx_rf / array_rx_if          : positive frequency OFFSETS from
%         band center (MHz), listed largest -> 0 (i.e. descending to 0).
%       array_tx_mask / array_rx_insert_loss: POSITIVE attenuation / insertion
%         loss (dB) at the matching offset, also ending in 0. (Negated here.)
%     Element i of an offset vector pairs with element i of its level vector.
%
%     TXSlope / RXSlope : roll-off beyond the last defined point.
%         []      -> extrapolate (log-linear) from the last two defined points.
%         numeric -> fixed slope in dB/decade (e.g. -60).
%
%     Delta_Freq_Step (optional) : OUTPUT frequency-separation step in MHz.
%       Default 1. This sets the spacing of the returned DeltaFreq/FDR_dB axis
%       ONLY; the internal integration step (dF, below) is finer and chosen
%       from the data. single_fdr_loss snaps to the nearest output point.
%
%   OUTPUTS:
%     FDR_dB     : FDR (dB) over the DeltaFreq grid.
%     ED, VD     : assembled two-sided TX mask / RX selectivity, [offset, dB].
%     OTR        : on-tune rejection = min(FDR_dB), taken straight from the
%                  computed curve (NOT clamped). It is ~0 dB when the RX
%                  passband is at least as wide as the TX emission, and rises
%                  toward 10*log10(B_T/B_R) when the emission is wider than the
%                  passband, so the receiver captures only part of the power.
%     DeltaFreq  : frequency-separation axis (MHz).
%     single_fdr_loss : FDR at the grid point nearest freq_sep.
%     trans_mask : [DeltaFreq', S_Tx'] -- the on-tune TX emission mask
%                  (dB-down) sampled over DeltaFreq.
%
%   STANDARDS NOTE:
%     FDR_dB is the discrete (uniform-grid Riemann-sum) form of SM.337-6
%     eq.(2): FDR(df) = 10*log10( SUM P(f) / SUM P(f)*H^2(f+df) ), with the TX
%     mask carried as power P(f)=10^(S_Tx/10) and the RX selectivity carried
%     in power-dB so that 10^(S_Rx/10) is H^2(f+df). At df=0 this evaluates to
%     the on-tune rejection of eq.(4) directly from the overlap integral; no
%     rectangular-bandwidth clamp is applied, so OTR reflects the actual
%     emission and selectivity shapes (including the RX skirts) rather than
%     the idealized 10*log10(B_T/B_R). Because H^2 <= 1, the denominator never
%     exceeds the numerator, so FDR_dB >= 0 everywhere by construction.
%
%   NOTE: 'app' is a vestigial App-Designer handle, unused; kept for call
%   compatibility and threaded through to the local subfunctions.

LogLin = 1;
CF = 0;

% --- optional OUTPUT grid step --------------------------------------------
if nargin < 9 || isempty(Delta_Freq_Step)
    Delta_Freq_Step = 1;            % MHz
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
end_freq = abs(temp_freq_sep);
start_freq = -1*end_freq;
DeltaFreq = start_freq:Delta_Freq_Step:end_freq;

% Collect Curve Data (mirror the one-sided inputs about 0).
% The on-tune split index MUST be taken from the OFFSET vector, which has a
% single, unique zero at on-tune. A level vector can legitimately carry more
% than one zero -- e.g. a flat in-band plateau that normalizes to 0 dB -- so
% locating the split with find(level==0,1) lands on the OUTERMOST in-band
% zero, mirrors the level about the wrong point, and leaves Mask_TX/Reject_RX
% a different length than BW_TX/BW_RX (the horzcat dimension mismatch below).
% Element i of an offset pairs with element i of its level, so the offset's
% zero index is the correct split for both vectors of a pair.
tx0 = find(array_tx_rf == 0, 1);    % on-tune index (TX)
rx0 = find(array_rx_if == 0, 1);    % on-tune index (RX)
if isempty(tx0) || isempty(rx0)
    error('FDR_ModelII_app:noOnTune', ...
        'Offset vectors must contain an on-tune point (offset 0).');
end

BW_TX     =  [-array_tx_rf          flip(array_tx_rf(1:tx0-1))]';
Mask_TX   =  [ array_tx_mask        flip(array_tx_mask(1:tx0-1))]';
BW_RX     =  [-array_rx_if          flip(array_rx_if(1:rx0-1))]';
Reject_RX = -[ array_rx_insert_loss flip(array_rx_insert_loss(1:rx0-1))]';

ED = [BW_TX, Mask_TX];
VD = [BW_RX, Reject_RX];

% On-tune index in each mirrored curve (single zero at band center), used to
% trim the one-sided halves fed to the extrapolator below.
RXidx = find(BW_RX == 0,1) - 1;
TXidx = find(BW_TX == 0,1) - 1;

% Internal integration step dF (MHz). The eq.2 numerator and denominator are
% uniform-grid Riemann sums, so dF must resolve the finest structure in the
% assembled curves -- in particular a steep band-edge transition sitting
% between two closely-spaced breakpoints (e.g. a ~52 dB emission drop across
% 1 MHz). A fixed 1-MHz step under-resolves that cliff and biases the
% integral (it read the on-tune rejection ~0.03 dB high). Tie dF to the
% smallest gap between adjacent breakpoints (data-driven, no fixed floor) and
% oversample each gap 10x; the integral is converged well before that.
brk = unique([array_tx_rf(:); array_rx_if(:)]);   % both curves share the 0 point
dF  = min(diff(brk)) / 10;

% Pre-extrapolate the curves to 0 dB to deal with NaNs
[BRx,BwRx] = Extrap0dB(app, flip(-array_rx_insert_loss(1:RXidx)), flip(array_rx_if(1:RXidx)), RXSlope);
[BTx,BwTx] = Extrap0dB(app, flip(-array_tx_mask(1:TXidx)), flip(array_tx_rf(1:TXidx)), TXSlope);

% --- VECTORIZATION NOTE: FDR via cross-correlation (replaces the loop) ----
% On a padded grid at the internal integration step dF, the eq.(2) curve is
%   FDR(df) = 10*log10( sum(P) / (P correlate H2)(df) )
% with P  = TX power spectrum (centered at 0) = 10^(S_tx/10)
%      H2 = RX power response (centered at 0) = 10^(S_rx/10).
% The numerator is constant (total TX power); the denominator is the TX
% spectrum correlated against the RX response slid by df. This is the same
% sum the loop did point-by-point -- just evaluated for all df at once.
pad = end_freq;                          % pad so every lag has support
f_ext = (-(end_freq+pad)):dF:(end_freq+pad);
if numel(f_ext) > 1e7
    error('FDR_ModelII_app:gridTooFine', ...
        ['Internal integration grid needs %d samples at dF = %g MHz, which ' ...
         'risks exhausting memory. Coarsen the closely-spaced input ' ...
         'breakpoints or narrow the frequency span.'], numel(f_ext), dF);
end
S_tx0 = makespectrumII(app,f_ext,CF,BTx,BwTx,TXSlope,LogLin);
S_rx0 = makespectrumII(app,f_ext,CF,BRx,BwRx,RXSlope,LogLin);
P  = 10.^(S_tx0/10);
H2 = 10.^(S_rx0/10);
Ne = numel(f_ext);
cc = conv(P, fliplr(H2));                % full correlation, no loop
num = sum(P);
lags = round(DeltaFreq/dF);              % DeltaFreq in dF samples
denom = cc(Ne + lags);                   % Ne = zero-lag index
FDR_dB = 10*log10(num ./ denom);
FDR_dB = FDR_dB(:);

% OTR is the on-tune rejection taken straight from the computed curve (the
% minimum FDR = maximum coupling). No clamp: when the RX passband is wider
% than the emission this is ~0 dB; when the emission is wider it is the real
% bandwidth-mismatch rejection, ~10*log10(B_T/B_R).
OTR = min(FDR_dB);

% FDR at the grid point nearest the requested separation
[~,ind_fdr_loss] = min(abs(DeltaFreq-freq_sep));
single_fdr_loss = FDR_dB(ind_fdr_loss);

% On-tune TX emission mask sampled over the DeltaFreq axis
S_Tx_ontune = makespectrumII(app,DeltaFreq,CF,BTx,BwTx,TXSlope,LogLin);
trans_mask = horzcat(DeltaFreq', S_Tx_ontune');

end

% =========================================================================
function [b,bw] = Extrap0dB(app,b,bw,Slope)
[m,n] = size(b);
for i = 1:m
    nans = isnan(bw(i,2:n))|isnan(b(i,2:n));
    keep = logical([1 ~nans]);
    b(i,1:n) = [b(i,keep) nan(1,sum(nans))];
    bw(i,1:n) = [bw(i,keep) nan(1,sum(nans))];
end
for i = m:-1:1
    if isnan(bw(i,1))
        if isempty(Slope)
            if sum(~isnan(bw(i,2:n)))<2     % delete row if < 2 non-NaN
                bw = bw(1:i-1,:);
                b = b(1:i-1,:);
            end
        else
            if sum(~isnan(bw(i,2:n)))<1     % delete row if < 1 non-NaN
                bw = bw(1:i-1,:);
                b = b(1:i-1,:);
            end
        end
    else
        if isempty(Slope)
            if sum(~isnan(bw(i,2:n)))<1
                bw = bw(1:i-1,:);
                b = b(1:i-1,:);
            end
        end
    end
end
[m,~] = size(b);
for i = 1:m
    if isnan(bw(i,1))
        if isnumeric(Slope) && ~isempty(Slope)
            b1 = b(i,1:find(isnan(b(i,2:end)), 1 ));
            bw1 = bw(i,1:find(isnan(bw(i,2:end)), 1 ));
            b1 = [b1 b1(end)+Slope];   %#ok
            bw1 = [bw1 10*bw1(end)];   %#ok
            if sum(~isnan(bw1(2:3)))==2
                b(i,1) = 0;
                bw(i,1) = 10^interp1(b1(2:3),log10(bw1(2:3)),b(i,1),'linear','extrap');
            end
        else
            if sum(~isnan(bw(i,2:3)))==2
                b(i,1) = 0;
                bw(i,1) = 10^interp1(b(i,2:3),log10(bw(i,2:3)),b(i,1),'linear','extrap');
            end
        end
    end
end
end

% =========================================================================
function S = makespectrumII(app,f,fc,b,bw,dB_dec,LogLin)
if b(1)~=0                            % insert Zero if needed
    b = [0 b];
    bw = [nan bw];
end
tmp = [0 isnan(b(2:end))|isnan(bw(2:end))];   %check for NaNs
if sum(tmp)
    b = b(1:find(tmp==1, 1 )-1);
    bw = bw(1:find(tmp==1, 1 )-1);
end
if isnumeric(dB_dec) && ~isempty(dB_dec)      %Add extrapolation point one decade out
    b = [b b(end)+dB_dec];
    bw = [bw 10*bw(end)];
end
if isnan(bw(1))                      % interpolate between points 2 and 3
    bw(1) = 10^interp1(b(2:3),log10(bw(2:3)),0,'linear','extrap');
elseif bw(1)==0                      % make equal to the step size
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
off = off(:).';                      % normalize to row
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