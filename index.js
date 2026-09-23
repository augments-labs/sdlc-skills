// Package entry for the OpenCode adapter.
//
// OpenCode 2.x resolves a configured plugin path as a directory and looks for
// `<dir>/server.js` then `<dir>/index.js`; a configured file path is refused
// outright ("configured plugin path must be a directory"). An installed
// package is resolved the same way, through this file as `main`. So the plugin
// lives at `.opencode/plugins/sdlc-skills.js`, where a contributor's checkout
// auto-discovers it, and is re-exported here for everyone else.
export { sdlcSkillsPlugin, setup } from "./.opencode/plugins/sdlc-skills.js";
export { default } from "./.opencode/plugins/sdlc-skills.js";
