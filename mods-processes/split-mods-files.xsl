<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" xmlns:saxon="http://saxon.sf.net/"
    xmlns="urn:schemas-microsoft-com:office:spreadsheet" xmlns:o="urn:schemas-microsoft-com:office:office" 
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:mods="http://www.loc.gov/mods/v3" extension-element-prefixes="saxon">
    
    <!-- xsl to chunk MODS collections into smaller collections. Note that this uses MODS 3.6. 
         @schemaLocation can be altered to use other versions. -->

    <xsl:output method="xml" indent="yes" encoding="UTF-8"/>
    
    <xsl:variable name="input-filename" select="replace(saxon:system-id(),'^.*/([^/]+)\.xml$','$1')"/>
    
    <xsl:param name="objects-per-file"/>
    
    <xsl:template match="/" exclude-result-prefixes="#all">
        <xsl:copy>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
        
    <xsl:template match="mods:modsCollection" exclude-result-prefixes="#all">
        <xsl:for-each-group select="mods:mods" group-starting-with="mods:mods[(position() -1) mod $objects-per-file = 0]">
            <xsl:variable name="filename" select="concat('chunked/',$input-filename,'_',position(),'.xml')"/>
            <xsl:result-document href="{$filename}" method="xml" encoding="utf-8" indent="yes" exclude-result-prefixes="#all">
                <modsCollection xmlns="http://www.loc.gov/mods/v3"
                    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                    xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-6.xsd">
                    <xsl:copy-of select="current-group()"/>
                </modsCollection>
            </xsl:result-document>
        </xsl:for-each-group>
    </xsl:template>
    
    
    <xsl:template match="* | @*" exclude-result-prefixes="#all">
        <xsl:copy>
            <xsl:apply-templates select="@* | *| text() | comment() | processing-instruction()"/>
        </xsl:copy>
    </xsl:template>
    
    
    <!-- keep comments and PIs						-->
    <xsl:template match="comment() | processing-instruction()">
        <xsl:copy-of select="."/>
    </xsl:template>

</xsl:stylesheet>
