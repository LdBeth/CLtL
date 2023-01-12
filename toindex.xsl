<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="text"  encoding="UTF-8" indent="no"/>
  <xsl:strip-space elements="*"/>
  <xsl:variable name="key" select="'Variable'"/>
  <xsl:template match="/index">
    <xsl:variable name="fi">
      <xsl:apply-templates mode="filter"/>
    </xsl:variable>
    <xsl:text>\bazindex{Variables}</xsl:text>
    <xsl:text>\begin{fnindex}&#xA;&#xA;</xsl:text>
    <xsl:apply-templates select="$fi"/>
    <xsl:text>&#xA;\end{fnindex}&#xA;</xsl:text>
  </xsl:template>
  <xsl:template match="entry">
    <xsl:text>\item {</xsl:text>
    <xsl:value-of select="id"/>
    <xsl:text>}{\cf </xsl:text>
    <xsl:value-of select="lead"/>
    <xsl:text>}, </xsl:text>
    <xsl:value-of select="items/item[1]/page"/>
    <xsl:text>&#xA;</xsl:text>
      <!--<xsl:for-each select="items/item[position() > 1]">
        <xsl:text>\subitem {\rm \lowercase {</xsl:text>
        <xsl:value-of select="type"/>
        <xsl:text>}}, </xsl:text>
        <xsl:value-of select="page"/>
        <xsl:text>&#xA;</xsl:text>
      </xsl:for-each> -->
  </xsl:template>

  <xsl:template mode="filter" match="text()"/>
  
  <xsl:template mode="filter" match="//item[type=$key]">
    <entry>
      <id><xsl:value-of select="../../id"/></id>
      <lead><xsl:value-of select="../../lead"/></lead>
      <xsl:copy-of select=".."/>
    </entry>
  </xsl:template>
</xsl:stylesheet>
