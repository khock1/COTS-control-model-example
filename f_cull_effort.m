function [ effort_quota ] = f_cull_effort( META )
%F_CULL_EFFORT Summary of this function goes here
%   Detailed explanation goes here


if META.COTS_boat_cull_effort==0%if total cull effort in km2 is not pre-specified, use calculations from number of days
    %average distance of 20 min swim in m; calculated from timed swims, assume AMPTO moves at same speed, although culls probably slower
    swimd=480;
    %average width covered during swim in m; manual reach; no changes due to habitat complexity etc, no slowdown due to high densities
    swimw=3;
    %average area covered by a diver per hour in m2; 4320m2, or 66x66m
    swima=swimd*swimw*3;
    %number of divers per boat; AMPTO
    divers=10;
    %number of hours dived per dive; AMPTO
    divet=2/3;
    %number of dives per diver per day; AMPTO; 2.67h per diver, 26.67h per boat
    diven=4;
    %area covered by boat per day; 115200m2, or 340x340m, or 0.1152km2
    area_day=swima*divers*divet*diven;
    %boat days at sea; AMPTO 220-240/year and some lost due to weather, so 100 days/6months; some also lost to travel, but not for now
    boat_days=META.COTS_cull_days;
    %effort quota, or area cleaned by boat per 6 months; 11.52km2 per 6 months
    effort_quota=area_day*boat_days;
end

end

