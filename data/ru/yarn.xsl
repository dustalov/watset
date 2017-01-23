<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:yarn="http://russianword.net">
  <xsl:output method="text" encoding="utf-8"/>
  <xsl:strip-space elements="*"/>
  <xsl:key name="words" match="/yarn:yarn/yarn:words/yarn:wordEntry" use="@id"/>
  <xsl:template match="/">
    <!-- Header. -->
    <xsl:text>id</xsl:text>
    <xsl:text>,</xsl:text>
    <xsl:text>version</xsl:text>
    <xsl:text>,</xsl:text>
    <xsl:text>grammar</xsl:text>
    <xsl:text>,</xsl:text>
    <xsl:text>words</xsl:text>
    <xsl:text>&#10;</xsl:text>
    <!-- Rows. -->
    <xsl:for-each select="/yarn:yarn/yarn:synsets/yarn:synsetEntry[yarn:word]">
      <!-- id -->
      <xsl:value-of select="substring(@id, 2)"/>
      <xsl:text>,</xsl:text>
      <!-- version -->
      <xsl:value-of select="@version"/>
      <xsl:text>,</xsl:text>
      <!-- grammar -->
      <xsl:for-each select="yarn:word">
        <xsl:sort select="key('words', @ref)/yarn:grammar" order="descending"/>
        <xsl:if test="position() = 1">
          <xsl:value-of select="key('words', @ref)/yarn:grammar"/>
        </xsl:if>
      </xsl:for-each>
      <xsl:text>,</xsl:text>
      <!-- words -->
      <xsl:for-each select="yarn:word[count(key('words', @ref)/yarn:word) &gt; 0]">
        <xsl:value-of select="key('words', @ref)/yarn:word"/>
        <xsl:if test="position() &lt; last()">
          <xsl:text>;</xsl:text>
        </xsl:if>
      </xsl:for-each>
      <xsl:text>&#10;</xsl:text>
    </xsl:for-each>
  </xsl:template>
</xsl:stylesheet>
