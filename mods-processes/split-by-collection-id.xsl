<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" xmlns:saxon="http://saxon.sf.net/"
    xmlns="urn:schemas-microsoft-com:office:spreadsheet" xmlns:o="urn:schemas-microsoft-com:office:office" 
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:mods="http://www.loc.gov/mods/v3" extension-element-prefixes="saxon">
    
    <!-- xsl to chunk MODS collections into files by collection id. -->

    <xsl:output method="xml" indent="yes" encoding="UTF-8"/>
    
    <xsl:template match="/" exclude-result-prefixes="#all">
        <xsl:copy>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:variable name="all-mods" select="/mods:modsCollection"/>
    
        
    <xsl:template match="mods:modsCollection" exclude-result-prefixes="#all">
        <!-- for each collection ID -->
        <xsl:for-each select="distinct-values(mods:mods/mods:relatedItem[@otherType = 'islandoraCollection']/mods:identifier)">
            <xsl:variable name="filename" select="concat('chunked/', replace(.,':','_'),'.xml')"/>
            <xsl:variable name="current-collection" select="."/>
            <xsl:result-document href="{$filename}" method="xml" encoding="utf-8" indent="yes" exclude-result-prefixes="#all">
                <modsCollection xmlns="http://www.loc.gov/mods/v3"
                    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                    xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-7.xsd">
                    <!-- write everyone that DOES have a collection ID (non pages/children) -->
                    <xsl:for-each select="$all-mods/mods:mods[mods:relatedItem[@otherType = 'islandoraCollection']/mods:identifier[. = $current-collection]]">
                        <xsl:copy-of select="."/>
                    </xsl:for-each>
                    <!-- for all the aggregate objects in the current group, add their children -->
                    <xsl:for-each select="$all-mods/mods:mods[mods:relatedItem[@otherType = 'islandoraCModel']/mods:identifier[matches(.,'(bookCModel|newspaperIssueCModel|compoundCModel)')]][mods:relatedItem[@otherType = 'islandoraCollection']/mods:identifier[. = $current-collection]]">
                        <xsl:variable name="current-parent-id" select="mods:identifier[@type = 'islandora']"/>
                        <xsl:message select="concat('current parent: ',$current-parent-id)"/>
                        <xsl:for-each select="$all-mods/mods:mods[not(mods:relatedItem[@otherType = 'islandoraCollection'])][mods:relatedItem[matches(@otherType,'(isPageOf|isChildOf)')]/mods:identifier[. = $current-parent-id]]">
                            <xsl:copy-of select="."/>
                        </xsl:for-each>
                    </xsl:for-each>
                </modsCollection>
            </xsl:result-document>
        </xsl:for-each>
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
