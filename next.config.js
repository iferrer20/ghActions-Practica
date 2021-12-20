module.exports = {
    eslint: {
        // Warning: This allows production builds to successfully complete even if
        // your project has ESLint errors.
        ignoreDuringBuilds: false,
        // Only run ESLint on the 'pages' and 'utils' directories during production builds (next build)
        dirs: ["."],
    },
}