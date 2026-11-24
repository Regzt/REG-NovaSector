import { Box } from 'tgui-core/components';

export const ColorPicker = (props) => {
  const {
    value = '#FFFFFF',
    tooltip,
    width = '36px',
    height = '24px',
    onCommit,
  } = props;

  return (
    <Box
      inline
      width={width}
      height={height}
      title={tooltip}
      style={{
        position: 'relative',
        overflow: 'hidden',
        border: '1px solid rgba(255, 255, 255, 0.2)',
        borderRadius: '3px',
      }}
    >
      <input
        type="color"
        value={value}
        onChange={(event) => onCommit?.(event.target.value)}
        style={{
          position: 'absolute',
          inset: 0,
          width: '100%',
          height: '100%',
          padding: 0,
          border: 0,
          background: 'transparent',
          cursor: 'pointer',
        }}
      />
    </Box>
  );
};
