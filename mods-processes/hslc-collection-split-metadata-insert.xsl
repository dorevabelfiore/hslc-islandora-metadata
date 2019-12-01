<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:saxon="http://saxon.sf.net/"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:mods="http://www.loc.gov/mods/v3"
    xmlns:cdm="http://www.oclc.org/contentdm" exclude-result-prefixes="xs"
    extension-element-prefixes="saxon" version="2.0">

    <!-- Template 
        - inserts metadata per map
        - revises collection ids per map by titles
        - updates titles selectively per map
    -->
    <!-- Currently assumes the collection is ONLY newspapers and pages -->

    <xsl:output method="xml" encoding="UTF-8" indent="yes"/>
    <xsl:strip-space elements="*"/>

    <!-- collection map -->
    <xsl:variable name="collection-map" select="doc('PA_Newspapers_1_Collections.xml')" exclude-result-prefixes="#all"/>
    <!-- titles to update -->
    <xsl:variable name="titles-to-update" exclude-result-prefixes="#all">
        <titles>
            <xsl:for-each select="$collection-map/collectionMap/group[@updateTitle='Y']/title">
                <title>
                    <xsl:value-of select="lower-case(.)"/>
                </title>
            </xsl:for-each>
        </titles>
    </xsl:variable>
    <!-- issues to update and their new metadata values -->
    <xsl:variable name="issues-to-update" exclude-result-prefixes="#all">
        <issues>
            <xsl:for-each select="$collection-map/collectionMap/group[@addMetadata='Y']">
                <issue>
                    <title>
                        <xsl:value-of select="lower-case(title)"/>
                    </title>
                    <xsl:copy-of select="description, subject, coverage, replaces, replacedBy"/>
                </issue>
            </xsl:for-each>
        </issues>
    </xsl:variable>

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
    <!-- update collection assignments for pages and compound children -->
    <xsl:template match="mods:mods[mods:relatedItem[matches(@otherType,'(isPageOf|isChildOf)')]]/mods:relatedItem[@otherType = 'islandoraCollection']" exclude-result-prefixes="#all">
        <xsl:variable name="parent-id" select="parent::mods:mods/mods:relatedItem[matches(@otherType,'(isPageOf|isChildOf)')]/mods:identifier[not(@type)]" as="xs:string"/>
        <xsl:variable name="parent-title" select="normalize-space(lower-case(ancestor::mods:modsCollection/mods:mods[mods:identifier[@type  = 'islandora'][. = $parent-id]]/mods:titleInfo/mods:title))"/>
        <!-- get the new collection ID, but bark if no match -->
        <xsl:variable name="target-collection-id">
            <xsl:choose>
                <xsl:when
                    test="$collection-map/collectionMap/group[title[lower-case(.) = $parent-title]]">
                    <xsl:value-of
                        select="$collection-map/collectionMap/group[title[lower-case(.) = $parent-title]]/collectionId"
                    />
                </xsl:when>
                <!-- some require manual mapping -->
                <xsl:when test="matches($parent-title,'(mount pleasant journal|mt. pleasant journal)')">
                    <xsl:text>papd:sstlp-mtpleasjl</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:message select="concat('No matching title for ', $parent-title)"/>
                    <xsl:text>UNKNOWN</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <!-- alter the collection ID -->
        <relatedItem xmlns="http://www.loc.gov/mods/v3" otherType="islandoraCollection" otherTypeAuth="dgi">
            <identifier>
                <xsl:value-of select="$target-collection-id"/>
            </identifier>
        </relatedItem>
        <xsl:message select="concat('new collection id ',$target-collection-id)"/>
    </xsl:template>
    
    <!-- collection ids, title updates, metadata mapping for newspaper/book/compound objects -->
    <xsl:template
        match="mods:mods[mods:relatedItem[@otherType = 'islandoraCModel']/mods:identifier[matches(.,'(bookCModel|newspaperIssueCModel|compoundCModel)')]]" exclude-result-prefixes="#all">
        <xsl:variable name="issue-title" select="normalize-space(lower-case(mods:titleInfo/mods:title))"/>
        <xsl:variable name="islandora-id" select="mods:identifier[@type = 'islandora']"/>
        <!-- get the new collection ID, but bark if no match -->
        <xsl:variable name="target-collection-id">
            <xsl:choose>
                <xsl:when
                    test="$collection-map/collectionMap/group[title[lower-case(.) = $issue-title]]">
                    <xsl:value-of
                        select="$collection-map/collectionMap/group[title[lower-case(.) = $issue-title]]/collectionId"
                    />
                </xsl:when>
                <!-- some require manual mapping -->
                <xsl:when test="matches($issue-title,'(mount pleasant journal|mt. pleasant journal)')">
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
            <xsl:apply-templates select="* except mods:relatedItem[@otherType = 'islandoraCollection']"/>
            <!-- alter the collection ID -->
            <relatedItem otherType="islandoraCollection" otherTypeAuth="dgi">
                <identifier>
                    <xsl:value-of select="$target-collection-id"/>
                </identifier>
            </relatedItem>
            <!-- since empty elements have been stripped for subject, coverage, replaces, replacedBy, we are _inserting_ not replacing metadata when directed -->
            <!-- if this is a book, compound, or newspaper issue, proceed -->
            <xsl:if test="mods:relatedItem[@otherType = 'islandoraCModel']/mods:identifier[matches(.,'(bookCModel|newspaperIssueCModel|compoundCModel)')]">
                <xsl:if test="$issues-to-update/issues/issue[title[. = $issue-title]]/subject[normalize-space()]">
                    <subject xmlns="http://www.loc.gov/mods/v3">
                        <topic>
                            <xsl:value-of select="$issues-to-update/issues/issue[title[. = $issue-title]]/subject[normalize-space()]"/>
                        </topic>
                    </subject>
                    <xsl:message select="concat('Updated subject at: ', $issue-title, ' with ', $issues-to-update/issues/issue[title[. = $issue-title]]/subject[normalize-space()])"/>
                </xsl:if>
                <xsl:if test="$issues-to-update/issues/issue[title[. = $issue-title]]/coverage[normalize-space()]">
                    <subject xmlns="http://www.loc.gov/mods/v3">
                        <geographic>
                            <xsl:value-of select="$issues-to-update/issues/issue[title[. = $issue-title]]/coverage[normalize-space()]"/>
                        </geographic>
                    </subject>
                    <xsl:message select="concat('Updated coverage at: ', $issue-title, ' with ', $issues-to-update/issues/issue[title[. = $issue-title]]/coverage[normalize-space()])"/>
                </xsl:if>
                <xsl:if test="$issues-to-update/issues/issue[title[. = $issue-title]]/replaces[normalize-space()]">
                    <relatedItem xmlns="http://www.loc.gov/mods/v3" otherType="Replaces" otherTypeAuthURI="http://dublincore.org/documents/2000/07/11/dcmes-qualifiers/">
                        <titleInfo>
                            <title><xsl:value-of select="$issues-to-update/issues/issue[title[. = $issue-title]]/replaces[normalize-space()]"/></title>
                        </titleInfo>
                    </relatedItem>
                    <xsl:message select="concat('Updated replaces at: ', $issue-title, ' with ', $issues-to-update/issues/issue[title[. = $issue-title]]/replaces[normalize-space()])"/>
                </xsl:if>
                <xsl:if test="$issues-to-update/issues/issue[title[. = $issue-title]]/replacedBy[normalize-space()]">
                    <relatedItem xmlns="http://www.loc.gov/mods/v3" otherType="Is Replaced By" otherTypeAuthURI="http://dublincore.org/documents/2000/07/11/dcmes-qualifiers/">
                        <titleInfo>
                            <title><xsl:value-of select="$issues-to-update/issues/issue[title[. = $issue-title]]/replacedBy[normalize-space()]"/></title>
                        </titleInfo>
                    </relatedItem>
                    <xsl:message select="concat('Updated replacedBy at: ', $issue-title, ' with ', $issues-to-update/issues/issue[title[. = $issue-title]]/replacedBy[normalize-space()])"/>
                </xsl:if>
                <xsl:if test="$issues-to-update/issues/issue[title[. = $issue-title]]/description[normalize-space()]">
                    <abstract xmlns="http://www.loc.gov/mods/v3" otherType="Is Replaced By" otherTypeAuthURI="http://dublincore.org/documents/2000/07/11/dcmes-qualifiers/">
                            <xsl:value-of select="$issues-to-update/issues/issue[title[. = $issue-title]]/description[normalize-space()]"/>
                    </abstract>
                    <xsl:message select="concat('Updated description at: ', $issue-title, ' with ', $issues-to-update/issues/issue[title[. = $issue-title]]/description[normalize-space()])"/>
                </xsl:if>
            </xsl:if>
        </mods>
    </xsl:template>
    
    <!-- update titles selectively -->
    <!-- if a collections is flagged for title update: on book and newspaper cModel objects that have a value for the date, concatenate it to the value of the title -->
    <xsl:template match="mods:titleInfo[parent::mods:mods]/mods:title[ancestor::mods:mods/mods:relatedItem[@otherType = 'islandoraCModel']/mods:identifier[matches(.,'(bookCModel|newspaperIssueCModel|(bookCModel|newspaperIssueCModel|compoundCModel))')]][ancestor::mods:mods/mods:originInfo/mods:dateIssued[normalize-space()]]" exclude-result-prefixes="#all">
        <xsl:variable name="issue-title" select="normalize-space(lower-case(ancestor::mods:mods/mods:titleInfo/mods:title))"/>
        <xsl:choose>
            <xsl:when test="$titles-to-update/titles/title[. = $issue-title]">
                <xsl:variable name="date" select="ancestor::mods:mods/mods:originInfo/mods:dateIssued[1]"/>
                <title xmlns="http://www.loc.gov/mods/v3">
                    <xsl:value-of select="normalize-space(concat(.,' ',$date))"/>
                </title>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
</xsl:stylesheet>
