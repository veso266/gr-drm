%% DRM transmitter

clear all
clc

%% calculate global variables, for the list of assumptions see drm_global_variables.m
run drm_global_variables

%% create dummy bit streams
msc_stream = ones(1, MSC.L_MUX); % one MSC multiplex frame
sdc_stream = zeros(1, SDC.L_SDC); % one SDC block
fac_stream = ones(1, FAC.L_FAC); % one FAC block

%% energy dispersal
msc_stream_scrambled = drm_scrambler(msc_stream);
sdc_stream_scrambled = drm_scrambler(sdc_stream);
fac_stream_scrambled = drm_scrambler(fac_stream);

%% partitioning
msc_stream_partitioned = drm_mlc_partitioning(msc_stream_scrambled, 'MSC', MSC);
sdc_stream_partitioned = drm_mlc_partitioning(sdc_stream_scrambled, 'SDC', SDC);
fac_stream_partitioned = drm_mlc_partitioning(fac_stream_scrambled, 'FAC', FAC);

%% encoding
msc_stream_encoded = drm_mlc_encoder(msc_stream_partitioned, 'MSC', MSC);
sdc_stream_encoded = drm_mlc_encoder(sdc_stream_partitioned, 'SDC', SDC);
fac_stream_encoded = drm_mlc_encoder(fac_stream_partitioned, 'FAC', FAC);

%% interleaving
msc_stream_interleaved = drm_mlc_interleaver(msc_stream_encoded, 'MSC', MSC);
sdc_stream_interleaved = drm_mlc_interleaver(sdc_stream_encoded, 'SDC', SDC);
fac_stream_interleaved = drm_mlc_interleaver(fac_stream_encoded, 'FAC', FAC);

%% bit to symbol mapping
msc_stream_mapped = drm_mapping(msc_stream_interleaved, 'MSC', MSC);
sdc_stream_mapped = drm_mapping(sdc_stream_interleaved, 'SDC', SDC);
fac_stream_mapped = drm_mapping(fac_stream_interleaved, 'FAC', FAC);

%% MSC cell interleaving
msc_stream_map_interl = drm_mlc_interleaver(msc_stream_mapped, 'MSC_cells', MSC);

%% build super transmission frame
super_tframe = drm_cell_mapping(msc_stream_map_interl, sdc_stream_mapped, fac_stream_mapped, MSC, SDC, FAC);

%% OFDM (complex baseband output)
complex_baseband = drm_ofdm(super_tframe, MSC);