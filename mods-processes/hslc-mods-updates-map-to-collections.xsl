<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:saxon="http://saxon.sf.net/"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:mods="http://www.loc.gov/mods/v3"
    xmlns:cdm="http://www.oclc.org/contentdm" exclude-result-prefixes="xs"
    extension-element-prefixes="saxon" version="2.0">

    <!-- Template utilizing a map newspaper issues to collections using their titles -->
    <!-- IMPORTANT: This needs to be run PRIOR to any processes to update titles -->
    <!-- Currently assumes the collection is ONLY newspapers and pages -->

    <xsl:output method="xml" encoding="UTF-8" indent="yes"/>
    <xsl:strip-space elements="*"/>

    <!-- collection map -->
    <xsl:variable name="collection-map" select="doc('PA_Newspapers_1_Collections.xml')"/>

    <!-- identity transform to copy through all nodes (except those with specific templates modifying them) -->
    <xsl:template match="/" exclude-result-prefixes="#all">
        <xsl:copy>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="* | @*" exclude-result-prefixes="#all">
        <xsl:copy>
            <xsl:apply-templates select="@* | * | text() | comment() | processing-instruction()"/>
        </xsl:copy>
    </xsl:template>

    <!-- keep comments and PIs						-->
    <xsl:template match="comment() | processing-instruction()">
        <xsl:copy-of select="."/>
    </xsl:template>

    <!-- updates -->
    <xsl:template
        match="mods:mods[mods:relatedItem[@otherType = 'islandoraCModel']/mods:identifier[. = 'islandora:newspaperIssueCModel']]" exclude-result-prefixes="#all">
        <xsl:variable name="issue-title" select="normalize-space(mods:titleInfo/mods:title)"/>
        <xsl:variable name="islandora-id" select="mods:identifier[@type = 'islandora']"/>
        <!-- get the new collection ID, but bark if no match -->
        <xsl:variable name="target-collection-id">
            <xsl:choose>
                <xsl:when
                    test="$collection-map/collectionMap/group[title[lower-case(.) = lower-case($issue-title)]]">
                    <xsl:value-of
                        select="$collection-map/collectionMap/group[title[lower-case(.) = lower-case($issue-title)]]/collectionId"
                    />
                </xsl:when>
                <!-- some require manual mapping -->
                <xsl:when test="matches(lower-case($issue-title),'(mount pleasant journal|mt. pleasant journal)')">
                    <xsl:text>papd:sstlp-mtpleasjl</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:message select="concat('No matching title for ', $issue-title)"/>
                    <xsl:text>UNKNOWN</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <mods xmlns="http://www.loc.gov/mods/v3"
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
            xmlns:xhtml="http://www.w3.org/1999/xhtml"
            xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-7.xsd"
            version="3.7">
            <xsl:copy-of select="* except mods:relatedItem[@otherType = 'islandoraCollection']"/>
            <!-- alter the collection ID -->
            <relatedItem otherType="islandoraCollection" otherTypeAuth="dgi">
                <identifier>
                    <xsl:value-of select="$target-collection-id"/>
                </identifier>
            </relatedItem>
        </mods>
    </xsl:template>




</xsl:stylesheet>
