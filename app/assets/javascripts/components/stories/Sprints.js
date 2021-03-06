import React from "react";
import PropTypes from "prop-types";
import Sprint from "./Sprint";

const propTypes = {
  sprints: PropTypes.array
};

const defaultProps = {
  sprints: [],
};

const renderSprints = (sprints, fetchStories) =>
  sprints.map(
    sprint =>
      <Sprint
        key={sprint.number}
        sprint={sprint}
        fetchStories={fetchStories}
      />
  )

const Sprints = ({ sprints, fetchStories }) => {
  if (!sprints.length) return null;

  return <div className="Sprints">{renderSprints(sprints, fetchStories)}</div>;
};

Sprint.propTypes = propTypes;
Sprint.defaultProps = defaultProps;

export default Sprints;
