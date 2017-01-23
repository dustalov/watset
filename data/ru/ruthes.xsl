<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="text" encoding="utf-8"/>
  <xsl:strip-space elements="*"/>
  <xsl:key name="synonyms" match="/ruthes/synonyms/entry_rel" use="@concept_id"/>
  <xsl:key name="entries" match="/ruthes/entries/entry" use="@id"/>
  <xsl:template match="/">
    <xsl:for-each select="/ruthes/concepts/concept">
      <!-- id -->
      <xsl:value-of select="@id"/>
      <xsl:text>&#9;</xsl:text>
      <!-- size -->
      <xsl:value-of select="1 + count(key('synonyms', @id))"/>
      <xsl:text>&#9;</xsl:text>
      <!-- words -->
      <xsl:value-of select="name"/>
      <xsl:for-each select="key('synonyms', current()/@id)">
        <xsl:for-each select="key('entries', current()/@entry_id)">
          <xsl:text>|</xsl:text>
          <xsl:value-of select="name"/>
        </xsl:for-each>
      </xsl:for-each>
      <xsl:text>&#10;</xsl:text>
    </xsl:for-each>
  </xsl:template>
</xsl:stylesheet>
