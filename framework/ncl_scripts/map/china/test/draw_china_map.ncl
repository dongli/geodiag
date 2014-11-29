load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

load "$GEODIAG_ROOT/geodiag.ncl"

begin

    wks = gsn_open_wks("pdf", "china_map")

    res = True
    res@resolutionLevel = 2
    res@isShowProvince = True
    res@provinceThickness = 1.0
    res@isShowCity = False
    res@cityThickness = 5.0
    res@isShowBeijingCounty = True
    res@beijingCountyColor = "red"
    res@beijingCountyThickness = 1.0
    res@isShowSouthChinaSea = False
    res@isShowRivers = False
    res@riverColor = "red"
    res@riverThickness = 1.0
    res@boundaryThickness = 2.0
    res@southChinaSeaMapWidth = 0.1
    setup_china_map(res) ; <--- set the resource for China map


    num_lon = 1441
    num_lat = 721

    lon = fspan(0, 360, num_lon)
    lat = fspan(-90, 90, num_lat)
    lon@long_name = "longitude"
    lat@long_name = "latitude"
    lon@units = "degrees_east"
    lat@units = "degrees_north"

    data = new((/num_lat,num_lon/), float)
    data!0 = "lat"
    data&lat = lat
    data!1 = "lon"
    data&lon = lon

    data = random_normal(0.0, 1.0, dimsizes(data))

    res@chinaMasks = (/"China"/)
    data_mask = get_china_mask(data, res)

    data = mask(data, data_mask, 1)

    res@cnFillOn        = True
    res@cnLinesOn       = False
    res@gsnSpreadColors = True
    res@lbLabelBarOn    = False
    res@cnLineLabelsOn  = False
    res@gsnAddCyclic    = False

    plot = gsn_csm_contour_map(wks, data, res)

    attach_china_map(wks, plot)
    draw(plot)

    frame(wks)

end
