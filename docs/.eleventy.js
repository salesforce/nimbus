module.exports = (eleventyConfig) => {
    eleventyConfig.addPassthroughCopy('css');
    return {
        dir: {
            input: 'site',
            output: 'dist'
        }
    }
}
