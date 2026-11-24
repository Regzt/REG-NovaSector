import {
  Box,
  Button,
  Flex,
  Icon,
  Input,
  NoticeBox,
  ProgressBar,
  Section,
  Stack,
  Table,
  Tabs,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';
import { createSearch } from 'tgui-core/string';
import { useBackend, useSharedState } from '../backend';
import { Window } from '../layouts';

const Upgrades = {
  advanced: 1 << 0,
  fast_cloning: 1 << 1,
};

type CircuitData = {
  name: string;
  desc: string;
  request_adv: BooleanLike;
  cost: number;
  path: string;
  icon?: string;
  extended_desc?: string;
};

type CategoryInfo = {
  cirrcusts?: CircuitData[];
  name: string;
};

type IntegratedPrinterData = {
  categories: CategoryInfo[];
  metal_amount: number;
  max_metal: number;
  debug_status: BooleanLike;
  cloning_status: BooleanLike;
  upgrades: number;
  clone_config_status: BooleanLike;
  has_programm: BooleanLike;
  print_end_time?: number;
  print_start_time?: number;
  world_time?: number;
  // vorecrimes
  used_space?: number;
  complexity?: number;
  metal_cost?: number;
  max_complexity?: number;
  max_space?: number;
};

// Поиск по всем схемам
const HardSearch = (
  categories: CategoryInfo[],
  search_text: string = '',
): CircuitData[] | null => {
  if (!search_text || categories.length === 0) return null;
  const allCircuits = categories.flatMap((cat) => cat.cirrcusts || []);
  const testSearch = createSearch<CircuitData>(search_text, (cir) => cir.name);
  return allCircuits.filter(testSearch);
};

const CheckPrint = (data: IntegratedPrinterData): BooleanLike => {
  if (data.metal_amount < (data.metal_cost ?? 0)) {
    return false;
  }
  if ((data.max_complexity ?? 0) < (data.complexity ?? 0)) {
    return false;
  }
  if ((data.max_space ?? 0) < (data.used_space ?? 0)) {
    return false;
  }

  return true;
};

// Компонент статуса принтера (металл + апгрейды)
const PrinterStatus = (props) => {
  const { data, act } = useBackend<IntegratedPrinterData>();
  const {
    metal_amount,
    max_metal,
    upgrades,
    debug_status,
    clone_config_status,
  } = data;
  const hasAdv = !!(upgrades & Upgrades.advanced);
  const hasFastClone = !!(upgrades & Upgrades.fast_cloning);

  return (
    <Section title="Состояние принтера">
      <Stack vertical>
        <Stack.Item>
          <Stack align="center">
            <Stack.Item minWidth="75px">Металл:</Stack.Item>
            <Stack.Item grow>
              <ProgressBar
                value={debug_status ? 1 : metal_amount / max_metal}
                ranges={{
                  good: [0.6, Infinity],
                  average: [0.3, 0.6],
                  bad: [0, 0.3],
                }}
              >
                {metal_amount} / {max_metal}
              </ProgressBar>
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item>
          <Stack align="center" wrap>
            <Stack.Item minWidth="75px">Статусы:</Stack.Item>
            <Stack.Item>
              <Stack>
                <Stack.Item>
                  <Button
                    icon="microchip"
                    color={hasAdv ? 'good' : 'transparent'}
                    selected={hasAdv}
                    tooltip={
                      hasAdv
                        ? 'Продвинутые схемы: Установлено'
                        : 'Продвинутые схемы: Нет'
                    }
                    tooltipPosition="top"
                  />
                </Stack.Item>
                <Stack.Item>
                  <Button
                    icon="dna"
                    color={hasFastClone ? 'good' : 'transparent'}
                    selected={hasFastClone}
                    tooltip={
                      hasFastClone
                        ? 'Быстрая печать: Установлено'
                        : 'Быстрая печать: Нет'
                    }
                    tooltipPosition="top"
                  />
                </Stack.Item>
                <Stack.Item>
                  <Button
                    icon="clone"
                    selected={!!clone_config_status}
                    tooltip={
                      clone_config_status
                        ? 'Клонирование включено'
                        : 'Клонирование запрещено конфигурацией сервера'
                    }
                    tooltipPosition="top"
                    color={clone_config_status ? 'good' : 'red'}
                  />
                </Stack.Item>
                {!!debug_status && (
                  <Stack.Item>
                    <Button
                      icon="bug"
                      color="purple"
                      selected
                      tooltip="Этот принтер принадлежит федерации магов."
                    />
                  </Stack.Item>
                )}
              </Stack>
            </Stack.Item>
            {!!(clone_config_status || debug_status) && (
              <Stack.Item>
                <Button
                  content="Загрузить схему"
                  onClick={() => act('print', { print: 'load' })}
                />
              </Stack.Item>
            )}
            {!!(data.has_programm && (clone_config_status || debug_status)) && (
              <>
                <Stack.Item>
                  <Button
                    disabled={!data.has_programm || !CheckPrint(data)}
                    content="Печать устройства"
                    onClick={() => act('print', { print: 'print' })}
                  />
                </Stack.Item>
                <Stack.Item>
                  <Button
                    icon="times"
                    color="red"
                    tooltip="Сбрасывает загруженную схему!"
                    onClick={() => act('print', { print: 'cancel' })}
                  />
                </Stack.Item>
                <Stack.Item grow>
                  <Box fontSize="11px" color="label">
                    Стоимость: <b>{data.metal_cost}</b> металла | Сложность:{' '}
                    <b>{data.complexity}</b> | Модулей: <b>{data.used_space}</b>
                  </Box>
                </Stack.Item>
              </>
            )}
          </Stack>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

// Компонент сетки схем
const CircuitsGrid = (props: {
  circuits?: CircuitData[];
  big_desc?: BooleanLike;
  rows?: number;
}) => {
  const { act, data } = useBackend<IntegratedPrinterData>();
  const { metal_amount } = data;
  const circuits = props.circuits || [];

  if (circuits.length === 0) {
    return <NoticeBox info>Нет схем для отображения</NoticeBox>;
  }
  const rows_in_line = props.rows ? props.rows : 3;
  const rows: CircuitData[][] = [];
  for (let i = 0; i < circuits.length; i += rows_in_line) {
    rows.push(circuits.slice(i, i + rows_in_line));
  }

  return (
    <Table>
      {rows.map((row, rowIndex) => (
        <Table.Row key={rowIndex}>
          {row.map((circuit, colIndex) => {
            const canAfford =
              (circuit.request_adv
                ? data.upgrades & Upgrades.advanced
                : true) &&
              (data.debug_status || metal_amount >= circuit.cost);
            let tooltip_msg = '';
            if (circuit.request_adv && !(data.upgrades & Upgrades.advanced)) {
              tooltip_msg = 'Нет улучшения!';
            } else if (!(data.debug_status || metal_amount >= circuit.cost)) {
              tooltip_msg = 'Недостаточно металла!';
            }

            return (
              <Table.Cell
                key={colIndex}
                style={{
                  width: '33.33%',
                  padding: '1px',
                  verticalAlign: 'top',
                }}
              >
                <Box
                  backgroundColor={
                    canAfford ? 'rgba(0, 0, 0, 0.24)' : 'rgba(79, 74, 74, 0.5)'
                  }
                  p={1}
                  style={{
                    borderRadius: '4px',
                    border: canAfford
                      ? '1px solid rgba(255, 255, 255, 0.14)'
                      : '1px solid rgba(252, 56, 56, 0.64)',
                    transition: 'all 0.1s',
                  }}
                >
                  <Stack vertical height="100%">
                    <Stack.Item>
                      <Stack align="flex-start">
                        {' '}
                        {/* Выравнивание по верхнему краю */}
                        <Stack.Item>
                          <Button
                            icon="question-circle"
                            tooltip={
                              props.big_desc
                                ? circuit.extended_desc
                                : circuit.desc
                            }
                            tooltipPosition="top"
                            color="transparent"
                            style={{ padding: 0 }}
                          />
                        </Stack.Item>
                        <Stack.Item>
                          {circuit.icon ? (
                            <img
                              src={`data:image/png;base64, ${circuit.icon}`}
                              style={{ width: '32px', height: '32px' }}
                            />
                          ) : (
                            <Icon name="microchip" size={2} />
                          )}
                        </Stack.Item>
                        <Stack.Item grow>
                          <Stack vertical>
                            <Stack.Item>
                              <Box bold>{circuit.name}</Box>
                            </Stack.Item>
                            {props.big_desc && (
                              <Stack.Item>
                                <Box fontSize="12px" color="label">
                                  {circuit.desc}
                                </Box>
                              </Stack.Item>
                            )}
                          </Stack>
                        </Stack.Item>
                      </Stack>
                    </Stack.Item>
                    <Stack.Item>
                      <Flex justify="space-between" align="center">
                        <Flex.Item>
                          <Box fontSize="12px" color="label">
                            Цена: <b>{circuit.cost}</b> металла
                          </Box>
                        </Flex.Item>
                        <Flex.Item>
                          <Button
                            content="Печать"
                            icon="print"
                            disabled={!canAfford}
                            onClick={() =>
                              act('build', { build: circuit.path })
                            }
                            tooltip={tooltip_msg}
                            tooltipPosition="top"
                          />
                        </Flex.Item>
                      </Flex>
                    </Stack.Item>
                  </Stack>
                </Box>
              </Table.Cell>
            );
          })}
          {row.length < rows_in_line &&
            Array.from({ length: rows_in_line - row.length }).map(
              (_, emptyIndex) => (
                <Table.Cell
                  key={`empty-${emptyIndex}`}
                  style={{
                    width: '33.33%',
                    padding: '1px',
                    verticalAlign: 'top',
                  }}
                >
                  <div style={{ visibility: 'hidden' }} />
                </Table.Cell>
              ),
            )}
        </Table.Row>
      ))}
    </Table>
  );
};

export const ComponentsViewer = (props) => {
  const { data } = useBackend<IntegratedPrinterData>();
  const [searchText, setSearchText] = useSharedState('searchPrinterText', '');
  const [tabID, setTabID] = useSharedState('tabPrinterIndex', 0);
  const [fullComp, setCompMode] = useSharedState<boolean>('setCompMode', false);

  const searchResults = HardSearch(data.categories, searchText);
  let circuitsToShow: CircuitData[] = [];
  if (searchText && searchResults) {
    circuitsToShow = searchResults;
  } else if (data.categories[tabID]) {
    circuitsToShow = data.categories[tabID].cirrcusts || [];
  }

  const handleCategoryChange = (index: number) => {
    setTabID(index);
    setSearchText('');
  };

  return (
    <Stack vertical fill>
      <Stack.Item>
        <PrinterStatus />
      </Stack.Item>

      <Stack.Item grow>
        <Stack fill>
          <Stack.Item minWidth="170px">
            <Section title="Категории" fill scrollable>
              <Tabs vertical>
                {data.categories.map((catInfo, index) => (
                  <Tabs.Tab
                    key={catInfo.name}
                    selected={index === tabID && !searchText}
                    onClick={() => handleCategoryChange(index)}
                  >
                    <Icon name="folder" mr={1} />
                    {catInfo.name}
                  </Tabs.Tab>
                ))}
              </Tabs>
            </Section>
          </Stack.Item>

          <Stack.Item grow>
            <Section
              fill
              scrollable
              title="Компоненты"
              buttons={
                <Stack>
                  <Stack.Item>
                    <Button
                      tooltip="Переключение вида"
                      icon="sticky-note"
                      selected={fullComp}
                      onClick={() => setCompMode(!fullComp)}
                    />
                  </Stack.Item>
                  <Stack.Item>
                    <Input
                      placeholder="Поиск по названию"
                      value={searchText}
                      onChange={(value) => setSearchText(value)}
                      width="220px"
                    />
                  </Stack.Item>
                  {!!searchText && (
                    <Stack.Item>
                      <Button
                        icon="times"
                        onClick={() => setSearchText('')}
                        tooltip="Сбросить поиск"
                      />
                    </Stack.Item>
                  )}
                </Stack>
              }
            >
              {searchText && searchResults?.length === 0 && (
                <NoticeBox danger>
                  По запросу {'"'}
                  {searchText}
                  {'"'} ничего не найдено
                </NoticeBox>
              )}
              <CircuitsGrid
                circuits={circuitsToShow}
                rows={fullComp ? 1 : 3}
                big_desc={fullComp}
              />
            </Section>
          </Stack.Item>
        </Stack>
      </Stack.Item>
    </Stack>
  );
};

export const CircuitPrinterUI = (props) => {
  const { data } = useBackend<IntegratedPrinterData>();
  return (
    <Window width={960} height={740} title="Интегральный принтер">
      <Window.Content>
        <Stack vertical fill>
          {!!data.debug_status && (
            <Stack.Item>
              <NoticeBox info>
                Принтер в дебаг режиме! Количество металла не ограничено!
              </NoticeBox>
            </Stack.Item>
          )}
          <Stack.Item grow>
            {data.cloning_status ? <CloneNotice /> : <ComponentsViewer />}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const formatTimeLeft = (seconds: number): string => {
  if (seconds <= 0) return '0:00';
  const mins = Math.floor(seconds / 60);
  const secs = Math.floor(seconds % 60);
  return `${mins}:${secs.toString().padStart(2, '0')}`;
};

export const CloneNotice = (props) => {
  const { data, act } = useBackend<IntegratedPrinterData>();
  const { print_end_time, print_start_time, world_time } = data;

  let progress = 0;
  let timeLeftSeconds = 0;

  if (
    print_end_time &&
    print_start_time &&
    world_time &&
    print_end_time > print_start_time
  ) {
    const totalDuration = print_end_time - print_start_time;
    const elapsed = world_time - print_start_time;
    progress = Math.min(1, Math.max(0, elapsed / totalDuration));

    const remainingTicks = print_end_time - world_time;
    timeLeftSeconds = Math.max(0, remainingTicks / 10);
  }

  const percent = Math.round(progress * 100);
  const timeText =
    timeLeftSeconds > 0
      ? `${percent}% (осталось ${formatTimeLeft(timeLeftSeconds)})`
      : `${percent}%`;

  return (
    <Box
      style={{
        display: 'flex',
        justifyContent: 'center',
        alignItems: 'center',
        height: '30%',
        width: '100%',
      }}
    >
      <NoticeBox
        danger
        style={{
          maxWidth: '450px',
          width: '100%',
          textAlign: 'center',
          borderRadius: '12px',
          boxShadow: '0 4px 12px rgba(0,0,0,0.2)',
        }}
      >
        <Stack vertical align="center">
          <Stack.Item>
            <h3
              style={{
                margin: '0 0 0.5rem 0',
                display: 'flex',
                alignItems: 'center',
                gap: '8px',
              }}
            >
              В процессе печати
              <Icon name="sync" spin size={1.5} />
            </h3>
          </Stack.Item>

          <Stack.Item style={{ width: '100%' }}>
            <ProgressBar
              value={progress}
              ranges={{
                good: [0.7, 1],
                average: [0.4, 0.7],
                bad: [0, 0.4],
              }}
            >
              {timeText}
            </ProgressBar>
          </Stack.Item>

          <Stack.Item>
            <Button
              color="red"
              content="Прервать"
              tooltip="Прерывает печать и возвращает ресурсы"
              onClick={() => act('print', { print: 'cancel' })}
              icon="ban"
            />
          </Stack.Item>
        </Stack>
      </NoticeBox>
    </Box>
  );
};
