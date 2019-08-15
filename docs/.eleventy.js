const syntaxHighlight = require("@11ty/eleventy-plugin-syntaxhighlight");

module.exports = eleventyConfig => {
    eleventyConfig.addPassthroughCopy("css");
    eleventyConfig.addPlugin(syntaxHighlight);

    return {
        dir: {
            input: "site",
            output: "dist"
        }
    };
};
