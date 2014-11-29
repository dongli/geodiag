; ------------------------------------------------------------------------------
; Description:
;
;   The following two procedures are used to set resource of the external
;   plotting and draw China map on it. The following blogs are refered:
;
;     http://bbs.sciencenet.cn/home.php?mod=space&uid=428536&do=blog&id=308001
;     http://blog.sciencenet.cn/home.php?mod=space&uid=428536&do=blog&id=308032
;
; Input:
;
;   - res: external plotting's resource
;   - wks: a workspace
;   - base_plot: the external plotting
;
; Configuration:
;
;   You can configure the China map plotting by using the following GEODIAG
;   resources before invoking 'setup_china_map':
;
;     - isShowProvince: show province boundaries or not
;     - provinceColor: set the color of province boundaries
;     - provinceThickness: set the thickness of province boundaries
;     - isShowCity: show city boundaries or not
;     - cityColor: set the color of city boundaries
;     - cityThickness: set the thickness of city boundaries
;     - isShowBeijingQuxian: show Beijing quxian boundaries or not
;     - beijingQuxianColor: set the color of Beijing quxian boundaries
;     - beijingQuxianThickness: set the thickness of Beijing quxian boundaries
;     - isShowBeijing3rdRing: show Beijing 3rd ring road or not
;     - beijing3rdRingColor: set the color of Beijing 3rd ring road
;     - beijing3rdRingThickness: set the thickness of Beijing 3rd ring road
;     - isShowBeijing4thRing: show Beijing 4th ring road or not
;     - beijing4thRingColor: set the color of Beijing 4th ring road
;     - beijing4thRingThickness: set the thickness of Beijing 4th ring road
;     - isShowBeijing5thRing: show Beijing 5th ring road or not
;     - beijing5thRingColor: set the color of Beijing 5th ring road
;     - beijing5thRingThickness: set the thickness of Beijing 5th ring road
;     - isShowBeijing6thRing: show Beijing 6th ring road or not
;     - beijing6thRingColor: set the color of Beijing 6th ring road
;     - beijing6thRingThickness: set the thickness of Beijing 6th ring road
;     - isShowSouthChinaSea: show South China Sea or not
;     - isShowRivers: show first class rivers or not
;     - boundaryColor: set the color of boundary
;     - boundaryThickness: set the thickness of boundary
;     - riverColor: set the color of rivers
;     - riverThickness: set the thickness of rivers
;     - southChinaSeaMapWidth: set the width of the small map
;
; Authors:
;
;   Li Dong - 2012-01-27
;
; Organization:
;
;   This work is supported by LASG/IAP (http://www.lasg.ac.cn/).
;
; Release note:
;
;   2012-01-27 - First release.
;   2012-02-17 - Add mask for plotting only China region.
;   2012-02-23 - Add option for plotting first class rivers
;   2012-03-15 - Add control on the thickness and color of the boundary
;                and rivers.
;   2013-01-28 - Add the control on the South China Sea small map.
;   2013-12-10 - Add isUseLowResolution option to speed up plotting.
;   2013-12-25 - Add city boundary plots.
;   2014-01-05 - Change to use NCL mask.
;   2014-08-29 - Add Beijing county boundaries and ring roads.
;   2014-10-10 - Rewrite GEODIAG, so refactor this script. Thanks ... for
;                adding province name to the province.shp so we can use that
;                shapefile to mask data with province boundaries.
; ------------------------------------------------------------------------------

china_map_data_root = "$GEODIAG_ROOT/framework/ncl_scripts/map/china/data"

config = True ; global internal configuration

procedure plot_shapefile(wks, base_plot, attach_plot, shapefile, res)
local f, tmp, num_features
begin

    f = addfile(shapefile, "r")

    ; The following commented lines produced messed up boundary lines.
    ; tmp = dimsizes(f->segments)
    ; num_features = tmp(1)

    ; resolution_level = config@resolutionLevel-1
    ; if (num_features .le. resolution_level) then
    ;     resolution_level = num_features-1
    ; end if

    ; res@gsSegments := f->segments(:,resolution_level)
    ; base_plot@$unique_string("china_map")$ = gsn_add_polyline(wks, attach_plot, f->x, f->y, res)

    segments = f->segments
    geometry = f->geometry
    segsDims = dimsizes(f->segments)
    geomDims = dimsizes(f->geometry)

    geom_segIndex = f@geom_segIndex
    geom_numSegs  = f@geom_numSegs
    segs_xyzIndex = f@segs_xyzIndex
    segs_numPnts  = f@segs_numPnts
    numFeatures   = geomDims(0)

    lon = f->x
    lat = f->y

    segNum = 0
    do i = 0, numFeatures-1
        start_seg = geometry(i, geom_segIndex)
        num_seg = geometry(i, geom_numSegs)
        do seg = start_seg, start_seg+num_seg-1
            start_point = segments(seg, segs_xyzIndex)
            end_point = start_point+segments(seg, segs_numPnts)-1
            base_plot@$unique_string("china_map")$ = \
                gsn_add_polyline(wks, attach_plot, \
                lon(start_point:end_point), lat(start_point:end_point), res)
            segNum = segNum+1
        end do
    end do

end

procedure set_default(res, att_name, default)
begin

    if (.not. isatt(res, att_name)) then
        res@$att_name$ = default
    end if

end

procedure transfer_attribute(res_from, res_to, att_name, default)
begin

    if (isatt(res_from, att_name)) then
        res_to@$att_name$ = res_from@$att_name$
        delete(res_from@$att_name$)
    else
        res_to@$att_name$ = default
    end if

end

procedure setup_china_map(res)
local i
begin

    res          = True
    res@gsnDraw  = False
    res@gsnFrame = False

    ; --------------------------------------------------------------------------
    ; transfer configuration for GEODIAG from res to internal config variable
    transfer_attribute(res, config, "resolutionLevel", 1) ; This is under developement.
    transfer_attribute(res, config, "isShowProvince", False)
    transfer_attribute(res, config, "provinceColor", "blue")
    transfer_attribute(res, config, "provinceThickness", 0.5)
    transfer_attribute(res, config, "isShowCity", False)
    transfer_attribute(res, config, "cityColor", "blue")
    transfer_attribute(res, config, "cityThickness", 0.5)
    transfer_attribute(res, config, "isShowBeijingCounty", False)
    transfer_attribute(res, config, "beijingCountyColor", "blue")
    transfer_attribute(res, config, "beijingCountyThickness", 0.5)
    do i = 3, 6
        transfer_attribute(res, config, "isShowBeijingRing"+sprinti("%d", i), False)
        transfer_attribute(res, config, "beijingRing"+sprinti("%d", i)+"Color", "blue")
        transfer_attribute(res, config, "beijingRing"+sprinti("%d", i)+"Thickness", 0.5)
    end do
    transfer_attribute(res, config, "isShowSouthChinaSea", False)
    transfer_attribute(res, config, "isShowRivers", False)
    transfer_attribute(res, config, "riverColor", "black")
    transfer_attribute(res, config, "riverThickness", 0.5)
    transfer_attribute(res, config, "boundaryColor", "black")
    transfer_attribute(res, config, "boundaryThickness", 0.5)
    transfer_attribute(res, config, "southChinaSeaMapWidth", 0.17)

    ; --------------------------------------------------------------------------
    ; set default NCL resources if user does not provide them
    set_default(res, "gsnMaximize", True)
    set_default(res, "mpMinLatF", 17.0)
    set_default(res, "mpMaxLatF", 55.0)
    set_default(res, "mpMinLonF", 72.0)
    set_default(res, "mpMaxLonF", 136.0)
    set_default(res, "mpOutlineOn", False)
    set_default(res, "mpLandFillColor", "white")
    set_default(res, "mpOceanFillColor", "white")
    set_default(res, "mpInlandWaterFillColor", "white")

end

procedure attach_china_map(wks, base_plot)
local china_shp, province_shp, beijing_county_shp, city_shp, river_shp, \
    show, color, thickness, res1, res2, res3, f, small_map, map
begin

    ; ------------------------------------------------------------------------
    ; draw china map from shapefile directly which is downloaded from:
    ;   National Fundamental Geographic Information System
    ;   http://nfgis.nsdi.gov.cn/nfgis/english/default.htm
    china_shp = china_map_data_root+"/china.shp"
    res1                    = True
    res1@gsLineColor        = config@boundaryColor
    res1@gsLineThicknessF   = config@boundaryThickness
    plot_shapefile(wks, base_plot, base_plot, china_shp, res1)

    ; --------------------------------------------------------------------------
    ; draw province boundaries
    if (config@isShowCity) then ; when plotting city, also plot province
        config@isShowProvince = True
    end if
    if (config@isShowProvince) then
        province_shp = china_map_data_root+"/province.shp"
        res1@gsLineColor = config@provinceColor
        res1@gsLineThicknessF = config@provinceThickness
        plot_shapefile(wks, base_plot, base_plot, province_shp, res1)
    end if

    ; --------------------------------------------------------------------------
    ; draw Beijing county boundaries and ring roads
    ; These data are provided by Xiaodong He from Institute of Urban
    ; Meteorology, China Meteorological Administration
    if (config@isShowBeijingCounty) then
        beijing_county_shp = china_map_data_root+"/beijing/county.shp"
        res1@gsLineColor = config@beijingCountyColor
        res1@gsLineThicknessF = config@beijingCountyThickness
        plot_shapefile(wks, base_plot, base_plot, beijing_county_shp, res1)
    end if
    do i = 3, 6
        show = "isShowBeijingRing"+sprinti("%d", i)
        color = "beijingRing"+sprinti("%d", i)+"Color"
        thickness = "beijingRing"+sprinti("%d", i)+"Thickness"
        if (config@$show$) then
            beijing_ring_shp = china_map_data_root+"/beijing/ring_"+sprinti("%d", i)+".shp"
            res1@gsLineColor = config@$color$
            res1@gsLineThicknessF = config@$thickness$
        end if
    end do

    ; --------------------------------------------------------------------------
    ; draw rivers
    if (config@isShowRivers) then
        river_shp = china_map_data_root+"/river.shp"
        res1@gsLineColor        = config@riverColor
        res1@gsLineThicknessF   = config@riverThickness
        plot_shapefile(wks, base_plot, base_plot, river_shp, res1)
    end if

    ; --------------------------------------------------------------------------
    ; draw city boundaries
    if (config@isShowCity)
        city_shp = china_map_data_root+"/city.shp"
        res1@gsLineColor = config@cityColor
        res1@gsLineThicknessF = config@cityThickness
        plot_shapefile(wks, base_plot, base_plot, city_shp, res1)
    end if

    ; --------------------------------------------------------------------------
    ; draw South China Sea area
    if (config@isShowSouthChinaSea) then
        res3                        = True
        res3@gsnDraw                = False
        res3@gsnFrame               = False
        res3@mpMinLatF              = 2.0
        res3@mpMaxLatF              = 23.5
        res3@mpMinLonF              = 105.0
        res3@mpMaxLonF              = 123.0
        res3@vpWidthF               = config@southChinaSeaMapWidth
        res3@mpLandFillColor        = "white"
        res3@mpOceanFillColor       = "white"
        res3@mpInlandWaterFillColor = "white"
        res3@tmXBOn                 = False
        res3@tmYLOn                 = False
        res3@tmXTOn                 = False
        res3@tmYROn                 = False

        small_map = gsn_csm_map(wks, res3)

        res1@gsLineColor            = config@boundaryColor
        res1@gsLineThicknessF       = config@boundaryThickness
        plot_shapefile(wks, base_plot, small_map, china_shp, res1)

        res4                    = True
        res4@amParallelPosF     = 0.495
        res4@amOrthogonalPosF   = 0.495
        res4@amJust             = "BottomRight"

        map = gsn_add_annotation(base_plot, small_map, res4)
    end if

end

function get_china_mask(data, res)
local china_masks, opt, province_shp, f, province_names, data_mask
begin

    if (.not. isatt(res, "chinaMasks")) then
        system("echo '[Error]: get_china_mask: Attribute chinaMasks is not provided!'")
        exit
    end if

    if (isstring(res@chinaMasks))
        china_masks = (/res@chinaMasks/)
    else
        china_masks = res@chinaMasks
    end if
    delete(res@chinaMasks)

    opt = True
    opt@shape_var = "NAME"
    opt@return_mask = True
    if (any(china_masks .eq. "China")) then
        china_shp = china_map_data_root+"/china.shp"
        opt@shape_names = "China"
        data_mask = shapefile_mask_data(data, china_shp, opt)
    else
        f = addfile(china_map_data_root+"/province.shp", "r")
        province_names = f->NAME

        do i = 0, dimsizes(china_masks)-1
            if (any(province_names .eq. china_masks(i))) then
                opt@shape_names = china_masks(i)
                if (.not. isdefined("data_mask")) then
                    data_mask = shapefile_mask_data(data, province_shp, opt)
                else
                    data_mask = data_mask+shapefile_mask_data(data, province_shp, opt)
                end if
            else
                system("echo '[Error]: get_china_mask: Mask "+china_masks(i)+" is not valid!'")
            end if
        end do
    end if

    return data_mask

end
