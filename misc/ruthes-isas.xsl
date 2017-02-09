<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="text" encoding="utf-8"/>
  <xsl:strip-space elements="*"/>
  <xsl:key name="concepts" match="/ruthes/concepts/concept" use="@id"/>
  <xsl:key name="synonyms" match="/ruthes/synonyms/entry_rel" use="@concept_id"/>
  <xsl:key name="entries" match="/ruthes/entries/entry" use="@id"/>
  <xsl:template match="/">
    <xsl:for-each select="/ruthes/relations/rel">
      <xsl:if test="@name = &quot;ВЫШЕ&quot;">
        <xsl:call-template name="relations">
          <xsl:with-param name="from" select="@from"/>
          <xsl:with-param name="to"   select="@to"/>
        </xsl:call-template>
      </xsl:if>
      <xsl:if test="@name = &quot;НИЖЕ&quot;">
        <xsl:call-template name="relations">
          <xsl:with-param name="from" select="@to"/>
          <xsl:with-param name="to"   select="@from"/>
        </xsl:call-template>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>
  <xsl:template name="relations">
    <xsl:param name="from"/>
    <xsl:param name="to"/>
    <!-- concept -> concept -->
    <xsl:value-of select="key('concepts', $from)/name"/>
    <xsl:text>&#9;</xsl:text>
    <xsl:value-of select="key('concepts', $to)/name"/>
    <xsl:text>&#10;</xsl:text>
    <xsl:for-each select="key('synonyms', $from)">
      <xsl:for-each select="key('entries', current()/@entry_id)">
        <xsl:variable name="hyponym" select="name"/>
        <!-- synonyms -> concept -->
        <xsl:value-of select="$hyponym"/>
        <xsl:text>&#9;</xsl:text>
        <xsl:value-of select="key('concepts', $to)/name"/>
        <xsl:text>&#10;</xsl:text>
        <xsl:for-each select="key('synonyms', $to)">
          <xsl:for-each select="key('entries', current()/@entry_id)">
            <!-- concept -> synonyms -->
            <xsl:value-of select="key('concepts', $from)/name"/>
            <xsl:text>&#9;</xsl:text>
            <xsl:value-of select="name"/>
            <xsl:text>&#10;</xsl:text>
            <!-- synonyms -> synonyms -->
            <xsl:value-of select="$hyponym"/>
            <xsl:text>&#9;</xsl:text>
            <xsl:value-of select="name"/>
            <xsl:text>&#10;</xsl:text>
          </xsl:for-each>
        </xsl:for-each>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:template>
</xsl:stylesheet>
