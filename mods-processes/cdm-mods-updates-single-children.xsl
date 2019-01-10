<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:saxon="http://saxon.sf.net/"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:mods="http://www.loc.gov/mods/v3"
    xmlns:cdm="http://www.oclc.org/contentdm"
    exclude-result-prefixes="xs"  extension-element-prefixes="saxon"
    version="2.0">
    
    <!-- Template to undo single child compounds. -->

    <xsl:output method="xml" encoding="UTF-8" indent="yes"/>

    <xsl:strip-space elements="*"/>
    
    <!-- grab info on compounds with one child -->
    <xsl:variable name="compounds-children">
        <compounds>
            <xsl:for-each select="/mods:modsCollection/mods:mods[mods:relatedItem[@otherType = 'islandoraCModel']/mods:identifier[. = 'islandora:compoundCModel']]">
                <xsl:variable name="compound-id" select="mods:identifier[@type = 'islandora']"/>
                <xsl:if test="count(parent::mods:modsCollection/mods:mods[mods:relatedItem[@otherType = 'isChildOf']/mods:identifier[. = $compound-id]]) = 1">
                <compound id="{$compound-id}">
                    <!-- list child -->
                        <xsl:for-each select="parent::mods:modsCollection/mods:mods[mods:relatedItem[@otherType = 'isChildOf']/mods:identifier[. = $compound-id]]">
                            <child id="{mods:identifier[@type = 'islandora']}"/>
                        </xsl:for-each>
                </compound>
                </xsl:if>
            </xsl:for-each>
        </compounds>
    </xsl:variable>
    
    
    <!-- identity transform to copy through all nodes (except those with specific templates modifying them -->    
    <xsl:template match="/" exclude-result-prefixes="#all">
        <xsl:copy>
            <xsl:apply-templates/>
        </xsl:copy>
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
    
    <!-- fix single child compounds -->
    <xsl:template
        match="mods:mods[mods:relatedItem[@otherType = 'islandoraCModel']/mods:identifier[. = 'islandora:compoundCModel']]" 
        exclude-result-prefixes="#all">
        <xsl:variable name="compound-id" select="mods:identifier[@type = 'islandora']"/>
        <xsl:choose>
            <!-- Compound with one child is NOT passed through. Its elements will be put in the child.  -->
            <xsl:when
                test="$compounds-children/compounds/compound[@id = $compound-id]">
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:apply-templates select="@* | *| text() | comment() | processing-instruction()"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- fix non-compound single children -->
    <xsl:template match="mods:mods[not(mods:relatedItem[@otherType = 'islandoraCModel']/mods:identifier[. = 'islandora:compoundCModel'])][mods:relatedItem[@otherType = 'isChildOf']]" exclude-result-prefixes="#all">
        <xsl:variable name="child-id" select="mods:identifier[@type = 'islandora']"/>
        <xsl:variable name="parent-id" select="mods:relatedItem[@otherType = 'isChildOf']/mods:identifier"/>
        <xsl:choose>
            <!-- if the only child of a compound, needs rebuild -->
            <xsl:when test="$compounds-children/*:compounds/*:compound/*:child[@id = $child-id]">
                <xsl:comment>Reconstructed Compound Child</xsl:comment>
                <mods  xmlns="http://www.loc.gov/mods/v3">
                    <!-- copy in metadata from compound, except for certain things... -->
                    <xsl:for-each select="ancestor::mods:modsCollection/mods:mods[mods:identifier[@type = 'islandora'][. = $parent-id]]/*[not(self::mods:relatedItem)]">
                        <xsl:copy-of select="."/>
                    </xsl:for-each>
                    <!-- keep things needed in the child -->
                    <xsl:for-each select="mods:relatedItem[matches(@otherType,'(islandoraCollection|islandoraCModel|OBJ)')]">
                        <xsl:copy-of select="."/>
                    </xsl:for-each>
                    <!-- if no collection association on the child it gets the parent's -->
                    <xsl:if test="not(mods:relatedItem[@otherType = 'islandoraCollection'])">
                        <xsl:copy-of select="ancestor::mods:modsCollection/mods:mods[mods:identifier[@type = 'islandora'][. = $parent-id]]/mods:relatedItem[@otherType = 'islandoraCollection']"/>
                    </xsl:if>
                </mods>
            </xsl:when>
            <!-- otherwise pass on through -->
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:apply-templates select="@* | *| text() | comment() | processing-instruction()"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

   
</xsl:stylesheet>
