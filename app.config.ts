module.exports = ({ config }) => {
    console.log(config.name); // prints 'My App'
    return {
      ...config,
    };
  };