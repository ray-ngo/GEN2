# -*- coding: utf-8 -*-
'''
The table below summarizes which versions of ArcGIS and Cube are compatible

                                      ArcGIS                  ArcPy       Result
       ESRI ArcGIS   Citilabs         Engine Runtime          Supported?  Machine         Note
       ------------  ----------      ----------------------   ----------  --------   --------------------

    57)ArcGIS 10.3   CUBE 6.4.1      (w/o ArcGIS runtime)       YES       Tested OK
    56)ArcGIS 10.2.2 CUBE 6.4.1      (w/o ArcGIS runtime)       YES       NOT TESTED
    55)ArcGIS 10.2.1 CUBE 6.4.1      (w/o ArcGIS runtime)       YES       NOT TESTED
    54)ArcGIS 10.2   CUBE 6.4.1      (w/o ArcGIS runtime)       YES       NOT TESTED
    53)ArcGIS 10.1   CUBE 6.4.1      (w/o ArcGIS runtime)       YES       NOT TESTED
    52)ArcGIS 10.0   CUBE 6.4.1      (w/o ArcGIS runtime)       YES       NOT TESTED
    51)ArcGIS  9.3   CUBE 6.4.1      (w/o ArcGIS runtime)       YES       NOT TESTED

    47)ArcGIS 10.3   CUBE 6.4        (w/o ArcGIS runtime)       N/A       FAILED      Cube issue: shp->NET. Informed Citilabs
    46)ArcGIS 10.2.2 CUBE 6.4        (w/o ArcGIS runtime)       N/A       NOT TESTED
    45)ArcGIS 10.2.1 CUBE 6.4        (w/o ArcGIS runtime)       N/A       NOT TESTED
    44)ArcGIS 10.2   CUBE 6.4        (w/o ArcGIS runtime)       N/A       NOT TESTED
    43)ArcGIS 10.1   CUBE 6.4        (w/o ArcGIS runtime)       N/A       NOT TESTED
    42)ArcGIS 10.0   CUBE 6.4        (w/o ArcGIS runtime)       N/A       NOT TESTED
    41)ArcGIS  9.3   CUBE 6.4        (w/o ArcGIS runtime)       N/A       NOT TESTED

    37)ArcGIS 10.3   CUBE 6.1.1      (w/o ArcGIS runtime)       *NO*      NOT TESTED
    36)ArcGIS 10.2.2 CUBE 6.1.1      (w/o ArcGIS runtime)       *NO*      FAILED
    35)ArcGIS 10.2.1 CUBE 6.1.1      (w/o ArcGIS runtime)       *NO*      FAILED
    34)ArcGIS 10.2   CUBE 6.1.1      (w/o ArcGIS runtime)       *NO*      NOT TESTED
    33)ArcGIS 10.1   CUBE 6.1.1      (w/o ArcGIS runtime)       YES       NOT TESTED
    32)ArcGIS 10.0   CUBE 6.1.1      (w/o ArcGIS runtime)       *NO*      NOT TESTED  BUG in ArcPy with ArcGIS 10.0
                                                                                      (Join doesn't work)

    31)ArcGIS  9.3   CUBE 6.1.1      (w/o ArcGIS runtime)       *NO*      NOT TESTED

    27)ArcGIS 10.3   CUBE 6.1.0 SP1  (w/o ArcGIS runtime)       *NO*      NOT TESTED
    26)ArcGIS 10.2.2 CUBE 6.1.0 SP1  (w/o ArcGIS runtime)       *NO*      NOT TESTED
    25)ArcGIS 10.2.1 CUBE 6.1.0 SP1  (w/o ArcGIS runtime)       *NO*      NOT TESTED
    24)ArcGIS 10.2   CUBE 6.1.0 SP1  (w/o ArcGIS runtime)       *NO*      NOT TESTED
    23)ArcGIS 10.1   CUBE 6.1.0 SP1  (w/o ArcGIS runtime)       YES       Tested OK
    22)ArcGIS 10.0   CUBE 6.1.0 SP1  (w/o ArcGIS runtime)       *NO*      FAILED      BUG in ArcPy with ArcGIS 10.0
                                                                                      (Join doesn't work)
    21)ArcGIS  9.3   CUBE 6.1.0 SP1  (w/o ArcGIS runtime)       *NO*      FAILED

    17)ArcGIS 10.3   CUBE 6.0.2      (w/o ArcGIS runtime)       *NO*      NOT TESTED
    16)ArcGIS 10.2.2 CUBE 6.0.2      (w/o ArcGIS runtime)       *NO*      NOT TESTED
    15)ArcGIS 10.2.1 CUBE 6.0.2      (w/o ArcGIS runtime)       *NO*      NOT TESTED
    14)ArcGIS 10.2   CUBE 6.0.2      (w/o ArcGIS runtime)       *NO*      NOT TESTED
    13)ArcGIS 10.1   CUBE 6.0.2      (w/o ArcGIS runtime)       YES       Tested OK
    12)ArcGIS 10.0   CUBE 6.0.2      (w/o ArcGIS runtime)       *NO*      FAILED      BUG in ArcPy with ArcGIS 10.0
                                                                                      (Join doesn't work)
    11)ArcGIS  9.3   CUBE 6.0.2      (w/o ArcGIS runtime)       *NO*      FAILED

# Cube with ArcGIS Engine Runtime (no ArcGIS software)
    7) No ArcGIS     CUBE 6.4.3      10.5       (Included)      YES       Tested OK
    6) No ArcGIS     CUBE 6.4.2      10.4       (Included)      YES       Tested OK. Somewhat unstable
    5) No ArcGIS     CUBE 6.4.1      10.3       (Included)      YES       Tested OK
    4) No ArcGIS     CUBE 6.4        10.3       (Included)      YES       FAILED
    3) No ArcGIS     CUBE 6.1.1      10.2       (Included)      YES       Tested OK
    2) No ArcGIS     CUBE 6.1.0 SP1  10.1       (Included)      YES       Tested OK
    1) No ArcGIS     CUBE 6.0.2      9.3.1 SP2  (Included)      *NO*      FAILED

'''

## Version is a suffix to TPB Model Version
__version__ = '2.3.58'

__all__ = [
    ]

#
# Revisions:
#       2016-04-10 - Revised to make the script run on ArcGIS/Engine Runtime 10.3
#       2014-03-24 - Created Script - KCP
#       2014-...
#

#
# import 'sys' to update search path
#
import sys, csv, operator

# include paths for ArcGIS 10.3, 10.4 installations
# use forward slashes '/' in place of Windows default backward slashes '\',
# otherwise use two backward slashes '\\'

# include paths for ArcGIS 10.5 full installation
sys.path.append("C:\\Program Files (x86)\\ArcGIS\\Desktop10.5\\arcpy")
sys.path.append("C:\\Program Files (x86)\\ArcGIS\\Desktop10.5\\bin")

# include paths for ArcGIS 10.4 full installation
sys.path.append("C:\\Program Files (x86)\\ArcGIS\\Desktop10.4\\arcpy")
sys.path.append("C:\\Program Files (x86)\\ArcGIS\\Desktop10.4\\bin")

# include paths for ArcGIS 10.3 full installation
sys.path.append("C:\\Program Files (x86)\\ArcGIS\\Desktop10.3\\arcpy")
sys.path.append("C:\\Program Files (x86)\\ArcGIS\\Desktop10.3\\bin")

# include paths for ArcGIS 10.2 full installation
sys.path.append("C:\\Program Files (x86)\\ArcGIS\\Desktop10.2\\arcpy")
sys.path.append("C:\\Program Files (x86)\\ArcGIS\\Desktop10.2\\bin")

# include paths for ArcGIS 10.1 full installation
sys.path.append("C:\\Program Files (x86)\\ArcGIS\\Desktop10.1\\arcpy")
sys.path.append("C:\\Program Files (x86)\\ArcGIS\\Desktop10.1\\bin")


# include paths for ArcGIS 10.5 runtime installation
sys.path.append("C:\\Program Files (x86)\\ArcGIS\\Engine10.5\\arcpy")
sys.path.append("C:\\Program Files (x86)\\ArcGIS\\Engine10.5\\bin")

# include paths for ArcGIS 10.4 runtime installation
sys.path.append("C:\\Program Files (x86)\\ArcGIS\\Engine10.4\\arcpy")
sys.path.append("C:\\Program Files (x86)\\ArcGIS\\Engine10.4\\bin")

# include paths for ArcGIS 10.3 runtime installation
sys.path.append("C:\\Program Files (x86)\\ArcGIS\\Engine10.3\\arcpy")
sys.path.append("C:\\Program Files (x86)\\ArcGIS\\Engine10.3\\bin")

# include paths for ArcGIS 10.2 runtime installation
sys.path.append("C:\\Program Files (x86)\\ArcGIS\\Engine10.2\\arcpy")
sys.path.append("C:\\Program Files (x86)\\ArcGIS\\Engine10.2\\bin")

# include paths for ArcGIS 10.1 runtime installation
sys.path.append("C:\\Program Files (x86)\\ArcGIS\\Engine10.1\\arcpy")
sys.path.append("C:\\Program Files (x86)\\ArcGIS\\Engine10.1\\bin")

#
# now import arcpy (with updated path variables) and other modules
#
try:
    import arcpy
#    from arcpy import env
    import os
    import datetime
    import traceback
except ImportError:
    MWCOG_PrintWriter( "ERROR: unable to import required modules!" )
    sys.exit(1)

#
# Global variables:
#

# Options are 'PercentWalk' or 'AreaWalk'
# PercentWalk' will result in integer percent-of-zone-that-is-walkable-to-transit
# AreaWalk'    will result in decimal square-miles-of-zone-that-is-walkable-to-transit

calc_type                                    = "AreaWalk"

dist_short                                   = "2640 Feet"
dist_long                                    = "5280 Feet"

# MUST Exist in Input TAZ,            INTEGER
my_TAZ_name                                  = "tazID"

# Used if exists otherwise created,   DOUBLE in Square Feet   (Do not set to 'Shape_Area')
my_TAZ_area_name                             = "TAZ_Area"
User_Input_TAZLandArea_Shapefile             = os.path.abspath("..\\..\\..\\TPBTAZ3722_TPBMod\\TAZLand3722.shp")

# If Input TAZ shapefile has 'Shape_Area' already in it, make this '1', else '0'
my_join_uniq_id                              = 1

# Options are 'FILE' or 'PERSONAL'
my_GDB_type                                  = "PERSONAL"

# for FILE use '.gdb' for PERSONAL use '.mdb'
my_GDB_name                                  = "Walkshed_Geodatabase.mdb"

# NOTE: Currently there is an issue with ArcGIS 10.1 which reports
#       'workspace or data source is read only'
#       after creating a file geo-database on a network drive.
#       So use only 'PERSONAL' geo-database option.

# # Options are 'FILE' or 'PERSONAL',
# my_GDB_type                                  = "FILE"

# for FILE use '.gdb' for PERSONAL use '.mdb'
# my_GDB_name                                  = "Walkshed_Geodatabase.gdb"

my_PWT_folder                              = os.path.abspath(".")
my_inp_folder                              = my_PWT_folder + "\\input"
my_out_folder                              = my_PWT_folder + "\\output"
my_tmp_folder                              = my_PWT_folder + "\\output"
my_GDB                                     = my_tmp_folder + "\\" + my_GDB_name

User_Input_All_PK_All_Stops_Shapefile      = my_inp_folder + "\\" + "ALLStops_PK.shp"
User_Input_All_OP_All_Stops_Shapefile      = my_inp_folder + "\\" + "ALLStops_OP.shp"
User_Input_All_DY_MetroLRT_Stops_Shapefile = my_inp_folder + "\\" + "MetroandLRT_AllDay.shp"
User_Output_Walkshed_CSV_File              = my_out_folder + "\\" + calc_type + ".csv"
User_Output_Walkshed_CSV_File_UnSorted     = my_out_folder + "\\" + calc_type + "_unsorted.csv"
User_Output_Walkshed_TXT_File              = my_out_folder + "\\" + calc_type + ".txt"
User_Output_Walkshed_Report_File           = my_out_folder + "\\" + calc_type + "_REPORT.prn"

# What fields to carry over to final output
my_out_fields                              = [my_TAZ_name, my_TAZ_area_name]

# What field to perform dissolve
my_dissolve_Fields                         = [my_TAZ_name]

# This is automatic geometry field created for every shapefile in geodatabase
my_join_Fieldlist                  = [ "Shape_Area" ]

my_buffer_sideType                 = "FULL"
my_buffer_endType                  = "ROUND"
my_buffer_dissolveType             = "NONE"
my_buffer_dissolveField            = ""

my_temp_buffer_dissolve_field_name = "Buf_Dis"

my_pctwlk_calcfield_codeblock      = """def CalcAttribute(tazarea, shedarea):
                                        if (shedarea):
                                            shedarea = (shedarea/(5280*5280))
                                            if (shedarea > tazarea):
                                                return round(100,8)
                                            else:
                                                return round((shedarea/tazarea)*100,8)
                                        else:
                                            return round(0,8)"""

my_arawlk_calcfield_codeblock      = """def CalcAttribute(tazarea, shedarea):
                                        if (shedarea):
                                            shedarea = (shedarea/(5280*5280))
                                            if (shedarea > tazarea):
                                                return round(tazarea,8)
                                            else:
                                                return round(shedarea,8)
                                        else:
                                            return round(0,8)"""

# Maximum length of the string for displaying full paths
my_rightstringlength                         = 75

###############################################################################
## Sub: MWCOG_BufferAndExport
###############################################################################

def MWCOG_BufferAndExport(point_shape, temp_prefix_short,
                          temp_prefix_long, startfresh, export):

    global my_out_fields
    global my_join_uniq_id

    #
    # Step 1: Message
    #

    mystarttime   = datetime.datetime.now()
    myendtime     = None
    myelapsedtime = None
    MWCOG_PrintWriter( "\n\tMWCOG_BufferAndExport (Started: " \
                      + str(mystarttime).split(".")[0] + ")" )
    MWCOG_PrintWriter( "\tShapefile  : " \
                      + str( ('..' + point_shape[(len(point_shape)\
                                                  -my_rightstringlength):])
                                               if len(point_shape) > my_rightstringlength
                                               else point_shape))
    MWCOG_PrintWriter( "\tShort Walk : " + str(dist_short) + ", Field = " \
                      + str(temp_prefix_short))
    MWCOG_PrintWriter( "\tLong Walk  : " + str(dist_long)  + ", Field = " \
                      + str(temp_prefix_long))

    #
    # Step 2: Create temporary file geodatabase
    #

    if (startfresh == 1):
        if (arcpy.Exists(my_GDB)) :
            MWCOG_PrintWriter( "\tdeleting geo-database ..." )
            arcpy.Delete_management(my_tmp_folder + "\\" + my_GDB_name)
        if (my_GDB_type == "PERSONAL"):
                MWCOG_PrintWriter( "\tcreating personal geo-database ...")
                arcpy.CreatePersonalGDB_management(my_tmp_folder,
                                                   my_GDB_name, "10.0")
        else:
                MWCOG_PrintWriter( "\tcreating file geo-database ...")
                arcpy.CreateFileGDB_management(my_tmp_folder,
                                               my_GDB_name, "10.0")
    else:
        if (arcpy.Exists(my_GDB)) : pass
        else:
                if (my_GDB_type == "PERSONAL"):
                        MWCOG_PrintWriter( "\tcreating personal geo-database ...")
                        arcpy.CreatePersonalGDB_management(my_tmp_folder,
                                                           my_GDB_name, "10.0")
                else:
                        MWCOG_PrintWriter( "\tcreating file geo-database ...")
                        arcpy.CreateFileGDB_management(my_tmp_folder,
                                                       my_GDB_name, "10.0")

    #
    # Step 3: Set Workspace(s)
    #

    arcpy.env.scratchWorkspace = my_GDB

    ## if (startfresh == 1):
    ##     MWCOG_PrintWriter( "\tlisting environment variables:" )
    ##     environments = arcpy.ListEnvironments()
    ##     for environment in environments:
    ##             envSetting = getattr(env, environment)
    ##             MWCOG_PrintWriter( "\t\t%-28s: %s" % (environment, envSetting) )

    #
    # Step 4: Work
    #

    try:
        #
        # Construct paths
        #
        temp_TAZ      = my_GDB        + "\\" + "TAZ_with_PercentWalkSheds"

        short_Temp1   = my_GDB        + "\\" + str(temp_prefix_short) + "Temp1"
        short_Temp2   = my_GDB        + "\\" + str(temp_prefix_short) + "Temp2"
        short_Temp3   = my_GDB        + "\\" + str(temp_prefix_short) + "Temp3"
        short_Temp4   = my_GDB        + "\\" + str(temp_prefix_short)
        short_OutFile = my_out_folder + "\\" + str(temp_prefix_short) + ".csv"

        long_Temp1    = my_GDB        + "\\" + str(temp_prefix_long)  + "Temp1"
        long_Temp2    = my_GDB        + "\\" + str(temp_prefix_long)  + "Temp2"
        long_Temp3    = my_GDB        + "\\" + str(temp_prefix_long)  + "Temp3"
        long_Temp4    = my_GDB        + "\\" + str(temp_prefix_long)
        long_OutFile  = my_out_folder + "\\" + str(temp_prefix_long)  + ".csv"

        #
        # Delete Existing Outputs
        #
        MWCOG_PrintWriter( "\tinitializing outputs ..." )

        if (startfresh == 1):

            # if starting afresh, copy TAZ layer into geodatabase and compute area
            if arcpy.Exists(temp_TAZ)  : arcpy.Delete_management(temp_TAZ)
            arcpy.CopyFeatures_management(User_Input_TAZLandArea_Shapefile, temp_TAZ)

            # check if area field exists else compute
            my_fieldList = arcpy.ListFields(temp_TAZ)

            my_fieldexists = False
            for my_field in my_fieldList:
                    if my_field.name == my_TAZ_area_name:
                            my_fieldexists = True
                            MWCOG_PrintWriter( "\t\tfound/using existing TAZ area field: " \
                                              + my_TAZ_area_name )
                            break
            if (my_fieldexists): pass
            else:
                    MWCOG_PrintWriter( "\t\tcreating TAZ area field: " \
                                      + my_TAZ_area_name )
                    arcpy.AddField_management(temp_TAZ, my_TAZ_area_name, "DOUBLE",
                                              14, "", "", my_TAZ_area_name)
                    arcpy.CalculateField_management( temp_TAZ, my_TAZ_area_name,
                                                    "!shape.area@SQUAREFEET!", "PYTHON")

        # delete old files
        if arcpy.Exists(short_Temp1)   : arcpy.Delete_management(short_Temp1)
        if arcpy.Exists(short_Temp2)   : arcpy.Delete_management(short_Temp2)
        if arcpy.Exists(short_Temp3)   : arcpy.Delete_management(short_Temp3)
        if arcpy.Exists(short_Temp4)   : arcpy.Delete_management(short_Temp4)
        if arcpy.Exists(short_OutFile) : arcpy.Delete_management(short_OutFile)

        if arcpy.Exists(long_Temp1)    : arcpy.Delete_management(long_Temp1)
        if arcpy.Exists(long_Temp2)    : arcpy.Delete_management(long_Temp2)
        if arcpy.Exists(long_Temp3)    : arcpy.Delete_management(long_Temp3)
        if arcpy.Exists(long_Temp4)    : arcpy.Delete_management(long_Temp4)
        if arcpy.Exists(long_OutFile)  : arcpy.Delete_management(long_OutFile)

        #
        # Process: Buffer & Compact database
        #
        MWCOG_PrintWriter( "\tbuffering ..." )

        arcpy.Buffer_analysis(point_shape, short_Temp1, dist_short,
                              my_buffer_sideType, my_buffer_endType,
                              my_buffer_dissolveType, my_buffer_dissolveField)
        arcpy.Compact_management( my_GDB )

        arcpy.Buffer_analysis(point_shape,  long_Temp1,  dist_long,
                              my_buffer_sideType, my_buffer_endType,
                              my_buffer_dissolveType, my_buffer_dissolveField)
        arcpy.Compact_management( my_GDB )

        #
        # Process: Add a field to dissolve on
        #
        MWCOG_PrintWriter( "\tadding a field for dissolving split buffers ..." )

        arcpy.AddField_management(short_Temp1, my_temp_buffer_dissolve_field_name,
                                  "SHORT", 1, "", "",
                                  my_temp_buffer_dissolve_field_name)
        arcpy.CalculateField_management(short_Temp1,
                                        my_temp_buffer_dissolve_field_name,
                                        "0", "PYTHON", "")

        arcpy.AddField_management( long_Temp1, my_temp_buffer_dissolve_field_name,
                                  "SHORT", 1, "", "",
                                  my_temp_buffer_dissolve_field_name)
        arcpy.CalculateField_management( long_Temp1,
                                        my_temp_buffer_dissolve_field_name,
                                        "0", "PYTHON", "")

        #
        # Process: Dissolve 1
        #
        MWCOG_PrintWriter( "\tdissolving any split buffers ..." )

        arcpy.Dissolve_management(short_Temp1, short_Temp2, "Buf_Dis", "",
                                  "MULTI_PART", "DISSOLVE_LINES")
        arcpy.Compact_management( my_GDB )

        arcpy.Dissolve_management( long_Temp1,  long_Temp2, "Buf_Dis", "",
                                  "MULTI_PART", "DISSOLVE_LINES")
        arcpy.Compact_management( my_GDB )

        #
        # Process: Intersect
        #
        MWCOG_PrintWriter( "\tintersecting ..." )

        arcpy.Intersect_analysis("'" + short_Temp2 + "'" + " #;" + \
                                 "'" + temp_TAZ + "'" + " #",
                                 short_Temp3, "NO_FID", "", "INPUT")
        arcpy.Compact_management( my_GDB )

        arcpy.Intersect_analysis("'" + long_Temp2 + "'" + " #;" + "'" \
                                 + temp_TAZ + "'" + " #",
                                 long_Temp3, "NO_FID", "", "INPUT")
        arcpy.Compact_management( my_GDB )

        #
        # Process: Dissolve 2
        #
        MWCOG_PrintWriter( "\tdissolving ..." )

        arcpy.Dissolve_management(short_Temp3, short_Temp4, my_dissolve_Fields,
                                  "", "MULTI_PART", "DISSOLVE_LINES")
        arcpy.Compact_management( my_GDB )

        arcpy.Dissolve_management( long_Temp3,  long_Temp4, my_dissolve_Fields,
                                  "", "MULTI_PART", "DISSOLVE_LINES")
        arcpy.Compact_management( my_GDB )

        #
        # Process: Join Short-Walk to Zone Layer
        #
        MWCOG_PrintWriter( "\tcomputing short-walk (" + calc_type + ") ..." )

        # join
        # Help: http://help.arcgis.com/en/arcgisdesktop/10.0/help/index.html#//001700000065000000
        arcpy.JoinField_management(temp_TAZ, my_TAZ_name, short_Temp4,
                                   my_TAZ_name, my_join_Fieldlist)



        # construct shape_area name
        # Below method is quirky, but this is how ArcGIS appends fields
        if   my_join_uniq_id == 0:
            my_shape_area_field = "Shape_Area"
        elif my_join_uniq_id == 1:
            my_shape_area_field = "Shape_Area_1"
        elif my_join_uniq_id == 2:
            my_shape_area_field = "Shape_Area_12"
        elif my_join_uniq_id == 3:
            my_shape_area_field = "Shape_Area_12_13"
        elif my_join_uniq_id == 4:
            my_shape_area_field = "Shape_Area_12_13_14"
        elif my_join_uniq_id == 5:
            my_shape_area_field = "Shape_Area_12_13_14_15"
        elif my_join_uniq_id == 6:
            my_shape_area_field = "Shape_Area_12_13_14_15_16"
        else: my_shape_area_field = "UNDEFINED"

        my_join_uniq_id += 1

        # calculate percent walk
        my_calcfield_expression = "CalcAttribute( !" + my_TAZ_area_name \
        + "!, !" + my_shape_area_field + "! )"
        arcpy.AddField_management(temp_TAZ, temp_prefix_short, "DOUBLE", "",
                                  "", "", "", "NULLABLE", "REQUIRED", "")

        # select based on calculation type
        if   (calc_type == "PercentWalk") :
                arcpy.CalculateField_management(temp_TAZ, temp_prefix_short,
                                                my_calcfield_expression, "PYTHON",
                                                my_pctwlk_calcfield_codeblock)
        elif (calc_type == "AreaWalk") :
                arcpy.CalculateField_management(temp_TAZ, temp_prefix_short,
                                                my_calcfield_expression, "PYTHON",
                                                my_arawlk_calcfield_codeblock)
        else:
                arcpy.AddError("ERROR: Un-recognized calc_type specified!")

        # make a note of this field
        my_out_fields.append(temp_prefix_short)

        #
        # Process: Join Long-Walk to Zone Layer
        #
        MWCOG_PrintWriter( "\tcomputing long-walk (" + calc_type + ") ..." )

        # join
        # Help: http://help.arcgis.com/en/arcgisdesktop/10.0/help/index.html#//001700000065000000
        arcpy.JoinField_management(temp_TAZ, my_TAZ_name, long_Temp4,
                                   my_TAZ_name, my_join_Fieldlist)

        # construct shape_area name
        # Below method is quirky, but this is how ArcGIS appends fields
        if   my_join_uniq_id == 0:
            my_shape_area_field = "Shape_Area"
        elif my_join_uniq_id == 1:
            my_shape_area_field = "Shape_Area_1"
        elif my_join_uniq_id == 2:
            my_shape_area_field = "Shape_Area_12"
        elif my_join_uniq_id == 3:
            my_shape_area_field = "Shape_Area_12_13"
        elif my_join_uniq_id == 4:
            my_shape_area_field = "Shape_Area_12_13_14"
        elif my_join_uniq_id == 5:
            my_shape_area_field = "Shape_Area_12_13_14_15"
        elif my_join_uniq_id == 6:
            my_shape_area_field = "Shape_Area_12_13_14_15_16"
        else: my_shape_area_field = "UNDEFINED"

        my_join_uniq_id += 1

        # calculate percent walk
        my_calcfield_expression = "CalcAttribute( !" + my_TAZ_area_name + "!, !" \
        + my_shape_area_field + "! )"
        arcpy.AddField_management(temp_TAZ, temp_prefix_long, "DOUBLE", "", "",
                                  "", "", "NULLABLE", "REQUIRED", "")

        # select based on calculation type
        if   (calc_type == "PercentWalk") :
                arcpy.CalculateField_management(temp_TAZ, temp_prefix_long,
                                                my_calcfield_expression, "PYTHON",
                                                my_pctwlk_calcfield_codeblock)
        elif (calc_type == "AreaWalk") :
                arcpy.CalculateField_management(temp_TAZ, temp_prefix_long,
                                                my_calcfield_expression, "PYTHON",
                                                my_arawlk_calcfield_codeblock)
        else:
                arcpy.AddError("ERROR: Un-recognized calc_type specified!")

        # make a note of this field
        my_out_fields.append(temp_prefix_long)

        #
        # Process: Export Feature Attribute to ASCII...
        #
        if (export==1):
            MWCOG_PrintWriter( "\twriting out " + calc_type + " Unsorted CSV file ..." )
            if arcpy.Exists(User_Output_Walkshed_CSV_File_UnSorted):
                arcpy.Delete_management(User_Output_Walkshed_CSV_File_UnSorted)
            arcpy.ExportXYv_stats(temp_TAZ, my_out_fields, "COMMA",
                                  User_Output_Walkshed_CSV_File_UnSorted,
                                  "ADD_FIELD_NAMES")

            MWCOG_PrintWriter( "\tsorting " + calc_type + " CSV file ..." )
            if arcpy.Exists(User_Output_Walkshed_CSV_File):
                arcpy.Delete_management(User_Output_Walkshed_CSV_File)

            with open(User_Output_Walkshed_CSV_File_UnSorted, "rb") as infile, \
            open(User_Output_Walkshed_CSV_File, "wb") as outfile:
               reader = csv.reader(infile)
               writer = csv.writer(outfile)
               # returns the headers or `None` if the input is empty
               headers = next(reader, None)
               if headers:
                   writer.writerow(headers)
               # 2 specifies that we want to sort according to the third column "TAZID"
               sortedlist = sorted(reader,  key = lambda x:int(x[2]))
               #now write the sorted result into new CSV file
               for row in sortedlist:
                   writer.writerow(row)

            MWCOG_PrintWriter( "\twriting out " + calc_type + " TXT file ..." )
            if arcpy.Exists(User_Output_Walkshed_TXT_File)  :
                arcpy.Delete_management(User_Output_Walkshed_TXT_File)

            # list fields
            fieldList = arcpy.ListFields(User_Output_Walkshed_CSV_File)

            # skip the fields 1,2 & 5  'XCoord, YCoord, TAZ, TAZ_AREA, MTLRTSHR,
            #                  MTLRTLNG, ALLPKSHR, ALLPKLNG, ALLOPSHR, ALLOPLNG'

            FieldsToSkip = ['XCoord', 'YCoord']

            # open input and process

            i = 1
            f = open(User_Output_Walkshed_TXT_File,'w')

            # variables for statistics

            my_num_taz                      = 0
            my_total_taz_area               = 0
            my_total_taz_walk_area          = 0
            my_total_taz_walk_pk_area       = 0
            my_total_taz_walk_op_area       = 0

            my_total_mtlrt_shr_area         = 0
            my_total_mtlrt_lng_area         = 0
            my_total_allpk_shr_area         = 0
            my_total_allpk_lng_area         = 0
            my_total_allop_shr_area         = 0
            my_total_allop_lng_area         = 0

            my_taz_list_zero_land_area      = []
            my_taz_list_zero_walk_area      = []
            my_taz_shr_list_pk_less_than_op = []
            my_taz_lng_list_pk_less_than_op = []

            # write header
            for field in fieldList:
                 if field.name in FieldsToSkip: i += 1
                 else:
                       if field.name == my_TAZ_name.upper() :
                        f.write('%6s'    % field.name)
                       elif i < len(fieldList)              :
                        f.write('%10s'   % field.name)
                       else                                 :
                        f.write('%10s\n' % field.name)
                       i += 1

            # write (copy) data
            rows = arcpy.SearchCursor(User_Output_Walkshed_CSV_File)
            for row in rows:
                i = 1
                my_mtlrt_shr = 0
                my_mtlrt_lng = 0
                my_allpk_shr = 0
                my_allpk_lng = 0
                my_allop_shr = 0
                my_allop_lng = 0

                for field in fieldList:
                     if field.name in FieldsToSkip: i += 1
                     else:
                           # write fields
                           if   field.name == my_TAZ_name.upper()      :
                               f.write('%6d' %  row.getValue(field.name) )
                           elif field.name == my_TAZ_area_name.upper() :
                               f.write('%10.4f' % round((row.getValue(field.name) / (5280*5280)), 4) )
                           elif i < len(fieldList)                     :
                               f.write('%10.4f' % round(row.getValue(field.name), 4))
                           else :
                               f.write('%10.4f\n' % round(row.getValue(field.name), 4))
                           i += 1

                           # save field value for checks
                           if( field.name == "MTLRTSHR" ) :
                               my_mtlrt_shr = round( row.getValue(field.name), 4)
                           if( field.name == "MTLRTLNG" ) :
                               my_mtlrt_lng = round( row.getValue(field.name), 4)
                           if( field.name == "ALLPKSHR" ) :
                               my_allpk_shr = round( row.getValue(field.name), 4)
                           if( field.name == "ALLPKLNG" ) :
                               my_allpk_lng = round( row.getValue(field.name), 4)
                           if( field.name == "ALLOPSHR" ) :
                               my_allop_shr = round( row.getValue(field.name), 4)
                           if( field.name == "ALLOPLNG" ) :
                               my_allop_lng = round( row.getValue(field.name), 4)

                # update stats on fields

                my_num_taz += 1
                my_total_taz_area += round( (row.getValue(my_TAZ_area_name.
                                                          upper()) / (5280*5280)), 4)

                if( row.getValue(my_TAZ_area_name.upper()) == 0 ):
                   my_taz_list_zero_land_area.append( str( row.
                                                          getValue(my_TAZ_name.upper())))

                if( (my_mtlrt_shr + my_mtlrt_lng + my_allpk_shr +
                     my_allpk_lng + my_allop_shr + my_allop_lng) == 0 ):
                   my_taz_list_zero_walk_area.append( str( row.
                                                          getValue(my_TAZ_name.upper())))

                my_total_mtlrt_shr_area +=  my_mtlrt_shr
                my_total_mtlrt_lng_area +=  my_mtlrt_lng
                my_total_allpk_shr_area +=  my_allpk_shr
                my_total_allpk_lng_area +=  my_allpk_lng
                my_total_allop_shr_area +=  my_allop_shr
                my_total_allop_lng_area +=  my_allop_lng

                if( my_allpk_shr < my_allop_shr ):
                   my_taz_shr_list_pk_less_than_op.append( str( row.getValue(my_TAZ_name.upper())))
                if( my_allpk_lng < my_allop_lng ):
                   my_taz_lng_list_pk_less_than_op.append( str( row.getValue(my_TAZ_name.upper())))

                my_total_taz_walk_area    += ( max( my_mtlrt_lng, my_allpk_lng, my_allop_lng ))
                my_total_taz_walk_pk_area += ( max( my_mtlrt_lng, my_allpk_lng               ))
                my_total_taz_walk_op_area += ( max( my_mtlrt_lng,               my_allop_lng ))

            del rows
            f.close()

            # report stats on fields
            if( calc_type == "AreaWalk" ):
                MWCOG_PrintWriter( "\nSUMMARY REPORT:"                                                                                                                                                                                                )
                MWCOG_PrintWriter( "\n\tNumber of TAZ Records in Output                                  : " \
                                  + str('{:,}'.format(my_num_taz))                                                                                                         )
                MWCOG_PrintWriter( "\tTotal TAZ LAND Area                                              : " \
                                  + str('{:9.4f} sq. mi.'.format(my_total_taz_area))                                                                                         )
                if( len(my_taz_list_zero_land_area) == 0 ) :
                        MWCOG_PrintWriter( "\tTAZs with Zero LAND Area                                         : NONE"                                                                                                                                )
                else:
                        MWCOG_PrintWriter( "\tTAZs with Zero LAND Area                                         : " \
                                          + "(Count=" + str(len(my_taz_list_zero_land_area)) + ") " \
                                          + ','.join(sorted(my_taz_list_zero_land_area, key=int)))
                MWCOG_PrintWriter( "\n\tTotal TAZ Long-Walk Area                                         : " \
                                  + str('{:9.4f} sq. mi. ({:6.2%} of TAZ Land Area)'
                                      .format(my_total_taz_walk_area,
                                              my_total_taz_walk_area/my_total_taz_area)))
                MWCOG_PrintWriter( "\tTotal TAZ Long-Walk (Peak Period) Area                           : " \
                                  + str('{:9.4f} sq. mi. ({:6.2%} of TAZ Land Area)'
                                      .format(my_total_taz_walk_pk_area,
                                              my_total_taz_walk_pk_area/my_total_taz_area)))
                MWCOG_PrintWriter( "\tTotal TAZ Long-Walk (Off-Peak Period) Area                       : " \
                                  + str('{:9.4f} sq. mi. ({:6.2%} of TAZ Land Area)'
                                      .format(my_total_taz_walk_op_area,
                                              my_total_taz_walk_op_area/my_total_taz_area)))
                if( len(my_taz_list_zero_walk_area) == 0 ) :
                        MWCOG_PrintWriter( "\tTAZs with Zero WALK Area                                         : NONE"                                                                                                                                )
                else:
                        MWCOG_PrintWriter( "\tTAZs with Zero WALK Area                                         : " \
                                          + "(Count=" + str(len(my_taz_list_zero_walk_area)) \
                                          + ") " + ','.join(sorted(my_taz_list_zero_walk_area,
                                                                   key=int)))
                MWCOG_PrintWriter( "\n\tTotal MTLRTSHR Area                                              : " \
                                  + str('{:9.4f} sq. mi. ({:6.2%} of TAZ Land Area)'
                                        .format(my_total_mtlrt_shr_area,
                                                my_total_mtlrt_shr_area/my_total_taz_area)))
                MWCOG_PrintWriter( "\tTotal MTLRTLNG Area                                              : " \
                                  + str('{:9.4f} sq. mi. ({:6.2%} of TAZ Land Area)'
                                        .format(my_total_mtlrt_lng_area,
                                                my_total_mtlrt_lng_area/my_total_taz_area)))
                MWCOG_PrintWriter( "\tTotal ALLPKSHR Area                                              : " \
                                  + str('{:9.4f} sq. mi. ({:6.2%} of TAZ Land Area)'
                                        .format(my_total_allpk_shr_area,
                                                my_total_allpk_shr_area/my_total_taz_area)))
                MWCOG_PrintWriter( "\tTotal ALLPKLNG Area                                              : " \
                                  + str('{:9.4f} sq. mi. ({:6.2%} of TAZ Land Area)'
                                        .format(my_total_allpk_lng_area,
                                                my_total_allpk_lng_area/my_total_taz_area)))
                MWCOG_PrintWriter( "\tTotal ALLOPSHR Area                                              : " \
                                  + str('{:9.4f} sq. mi. ({:6.2%} of TAZ Land Area)'
                                        .format(my_total_allop_shr_area,
                                                my_total_allop_shr_area/my_total_taz_area)))
                MWCOG_PrintWriter( "\tTotal ALLOPLNG Area                                              : " \
                                  + str('{:9.4f} sq. mi. ({:6.2%} of TAZ Land Area)'
                                        .format(my_total_allop_shr_area,
                                                my_total_allop_shr_area/my_total_taz_area)))
                if( len(my_taz_shr_list_pk_less_than_op) == 0 ) :
                        MWCOG_PrintWriter( "\n\tTAZs with Short-Walk Less in Peak Period than in Off-Peak Period : NONE" )
                else:
                        MWCOG_PrintWriter( "\n\tTAZs with Short-Walk Less in Peak Period than in Off-Peak Period : " \
                                          + "(Count=" + str(len(my_taz_shr_list_pk_less_than_op)) + ") " \
                                          + ','.join(sorted(my_taz_shr_list_pk_less_than_op, key=int))      )
                if( len(my_taz_lng_list_pk_less_than_op) == 0 ) :
                        MWCOG_PrintWriter( "\tTAZs with  Long-Walk Less in Peak Period than in Off-Peak Period : NONE\n" )
                else:
                        MWCOG_PrintWriter( "\tTAZs with  Long-Walk  Less in Peak Period than in Off-Peak Period : " \
                                          + "(Count=" + str(len(my_taz_lng_list_pk_less_than_op)) \
                                          + ") " + ','.join(sorted(my_taz_lng_list_pk_less_than_op, key=int)) + "\n" )
    except:
        #
        # Get the traceback object
        #
        tb = sys.exc_info()[2]
        tbinfo = traceback.format_tb(tb)[0]

        #
        # Concatenate information together concerning the error into a message string
        #
        pymsg = "PYTHON ERRORS:\nTraceback info:\n" + tbinfo + "\nError Info:\n"\
         + str(sys.exc_info()[1])
        msgs = "ArcPy ERRORS:\n" + arcpy.GetMessages(2) + "\n\n\n"

        #
        # Return python error messages for use in script tool or Python Window
        #
        arcpy.AddError(pymsg)
        arcpy.AddError(msgs)

        return 1

    myendtime     = datetime.datetime.now()
    myelapsedtime = myendtime - mystarttime
    MWCOG_PrintWriter( "\tMWCOG_BufferAndExport (Finished: "\
                      + str(myendtime).split(".")[0] + ", Elapsed: " \
                      + str(myelapsedtime).split(".")[0] + ")" )
    return 0

###############################################################################
## Sub: MWCOG_BufferAndExport END
###############################################################################

###############################################################################
## Sub: MWCOG_PrintWriter
###############################################################################

def MWCOG_PrintWriter( message ):

    # global report file handle
    global my_report_file_handle

    # show message on screen
    print ( str(message) )

    # write message to report file
    my_report_file_handle.write( str(message) + '\n' )

###############################################################################
## Sub: MWCOG_PrintWriter END
###############################################################################

###############################################################################
## Main: Begin
###############################################################################

if __name__ == '__main__':

    mystarttime   = datetime.datetime.now()
    myendtime     = None
    myelapsedtime = None

    my_report_file_handle = open(User_Output_Walkshed_Report_File, 'w', 0)

    MWCOG_PrintWriter ("BEGIN ArcPy Walkshed Process (Started: " \
                       + str(mystarttime).split(".")[0] + ")")

    # Process the three shapefiles in sequence
    #               Arg1=Shapefile, Arg2=NameforShortWalk, Arg3=NameforLongWalk,
    #               Arg4=StartfromScratch, Arg5=WriteOutputFile

    if( MWCOG_BufferAndExport( User_Input_All_DY_MetroLRT_Stops_Shapefile,
                              "MTLRTShr",  "MTLRTLng", 1, 0) == 1 ):
        sys.exit(1)
    if( MWCOG_BufferAndExport(      User_Input_All_PK_All_Stops_Shapefile,
                              "ALLPKShr",  "ALLPKLng", 0, 0) == 1 ):
        sys.exit(1)
    if( MWCOG_BufferAndExport(      User_Input_All_OP_All_Stops_Shapefile,
                              "ALLOPShr",  "ALLOPLng", 0, 1) == 1 ):
        sys.exit(1)

    ## debug individual
    # if( MWCOG_BufferAndExport( User_Input_All_DY_MetroLRT_Stops_Shapefile,
    #    "MTLRTShr",  "MTLRTLng", 1, 1) == 1 ): sys.exit(1)
    # if( MWCOG_BufferAndExport(      User_Input_All_PK_All_Stops_Shapefile,
    ## debug individual
    #    "ALLPKShr",  "ALLPKLng", 1, 1) == 1 ): sys.exit(1)
    ## debug individual
    # if( MWCOG_BufferAndExport(      User_Input_All_OP_All_Stops_Shapefile,
    #    "ALLOPShr",  "ALLOPLng", 1, 1) == 1 ): sys.exit(1)

    ## fast run for debugging
    # if( MWCOG_BufferAndExport( User_Input_All_DY_MetroLRT_Stops_Shapefile,
    #   "MTLRTShr",  "MTLRTLng", 1, 0) == 1 ): sys.exit(1)
    ## fast run for debugging
    # if( MWCOG_BufferAndExport( User_Input_All_DY_MetroLRT_Stops_Shapefile,
        #"ALLPKShr",  "ALLPKLng", 0, 0) == 1 ): sys.exit(1)
    ## fast run for debugging
    # if( MWCOG_BufferAndExport( User_Input_All_DY_MetroLRT_Stops_Shapefile,
    #   "ALLOPShr",  "ALLOPLng", 0, 1) == 1 ): sys.exit(1)

    myendtime     = datetime.datetime.now()
    myelapsedtime = myendtime - mystarttime

    MWCOG_PrintWriter ("\nEND ArcPy Walkshed Process (Finished: " \
                       + str(myendtime).split(".")[0] + ", Elapsed: " \
                       + str(myelapsedtime).split(".")[0] + ")")

    my_report_file_handle.close()

###############################################################################
## Main: End
###############################################################################
