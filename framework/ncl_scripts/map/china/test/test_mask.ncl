load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

load "$GEODIAG_ROOT/geodiag.ncl"

begin

    province_shp = "$GEODIAG_ROOT/framework/ncl_scripts/map/china/data/province.shp"

    f = addfile(province_shp, "r")

    segments = f->segments
    geometry = f->geometry
    segsDims = dimsizes(segments)
    geomDims = dimsizes(geometry)

    geom_segIndex = f@geom_segIndex
    geom_numSegs  = f@geom_numSegs
    segs_xyzIndex = f@segs_xyzIndex
    segs_numPnts  = f@segs_numPnts

    lines = new(segsDims(0), graphic)
    numFeatures = geomDims(0)

    print(getfilevarnames(f))
    print(f->NAME)
    print(numFeatures)

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

    opt = True
    opt@shape_var = "NAME"
    opt@shape_names = (/"Henan"/)

    masked_data = shapefile_mask_data(data, province_shp, opt)

    printVarSummary(masked_data)

    wks = gsn_open_wks("pdf", "test_mask")

    gsn_define_colormap(wks, "rainbow")

    res = True
    res@cnFillOn = True
    res@cnLinesOn = False
    res@gsnSpreadColors = True
    res@gsnAddCyclic = False
    res@mpMinLonF = 105.0
    res@mpMaxLonF = 120.0
    res@mpMinLatF = 30.0
    res@mpMaxLatF = 40.0

    plot = gsn_csm_contour_map(wks, masked_data, res)

end
