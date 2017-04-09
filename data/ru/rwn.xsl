<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="text" encoding="utf-8"/>
  <xsl:strip-space elements="*"/>
  <xsl:key name="senses" match="/rwn/senses/sense" use="@id"/>
  <xsl:template match="/">
    <xsl:for-each select="/rwn/synsets/synset">
      <!-- id -->
      <xsl:value-of select="@id"/>
      <xsl:text>&#9;</xsl:text>
      <!-- count -->
      <xsl:value-of select="count(./sense)"/>
      <xsl:text>&#9;</xsl:text>
      <!-- words -->
      <xsl:for-each select="./sense">
        <xsl:if test="position() &gt; 1">
          <xsl:text>|</xsl:text>
        </xsl:if>
        <xsl:value-of select="key('senses', @id)/@name"/>
      </xsl:for-each>
      <xsl:text>&#10;</xsl:text>
    </xsl:for-each>
  </xsl:template>
</xsl:stylesheet>
